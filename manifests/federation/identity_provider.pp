# == class: keystone::federation::identity_provider
#
# == Parameters
#
# [*certfile*]
#   (Required) Path of the certfile for SAML signing. The path can not
#   contain a comma. (string value).
#   Defaults to $::keystone::ssl_ca_certs value.
#
# [*keyfile*]
#   (Required) Path of the keyfile for SAML signing. The path can not
#   contain a comma (string value).
#   Defaults to $::keystone::ssl_ca_key value.
#
# [*idp_entity_id*]
#   (Required) Entity ID value for unique Identity Provider identification
#   (string value).
#
# [*idp_sso_endpoint*]
#   (Required) Identity Provider Single-Sign-On service value (string value).
#
# [*idp_metadata_path*]
#   (Required) Path to the Identity Provider Metadata file (string value).
#
# [*idp_organization_name*]
#   (Optional) Organization name the installation belongs to (string value).
#   Defaults to 'undef'.
#
# [*idp_organization_display_name*]
#   (Optional) Organization name to be displayed (string value).
#   Defaults to 'undef'.
#
# [*idp_organization_url*]
#   (Optional) URL of the organization (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_company*]
#   (Optional) Company of contact person (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_name*]
#   (Optional) Given name of contact person (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_surname*]
#   (Optional) Surname of contact person (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_email*]
#   (Optional) Email address of contact person (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_telephone*]
#   (Optional) Telephone number of contact person (string value).
#   Defaults to 'undef'.
#
# [*idp_contact_type*]
#   (Optional) Contact type. Allowed values are: technical, support,
#   administrative billing, and other (string value).
#   Defaults to 'undef'.
#
# [*user*]
#  (Optional) User with access to keystone files. (string value)
#  Defaults to 'keystone'.
#
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# == Dependencies
# == Examples
# == Authors
#
#   Iury Gregory iurygregory@gmail.com
#
# == Copyright
#
#   Copyright 2013 eNovance <licensing@enovance.com>
#
class keystone::federation::identity_provider(
  $idp_entity_id,
  $idp_sso_endpoint,
  $idp_metadata_path,
  $certfile                      = $::keystone::ssl_ca_certs,
  $keyfile                       = $::keystone::ssl_ca_key,
  $user                          = 'keystone',
  $idp_organization_name         = undef,
  $idp_organization_display_name = undef,
  $idp_organization_url          = undef,
  $idp_contact_company           = undef,
  $idp_contact_name              = undef,
  $idp_contact_surname           = undef,
  $idp_contact_email             = undef,
  $idp_contact_telephone         = undef,
  $idp_contact_type              = undef,
  $package_ensure                = present,
) {

  include ::keystone::deps
  include ::keystone::params

  if $::keystone::service_name != 'httpd' {
    fail ('Keystone need to be running under Apache for Federation work.')
  }

  ensure_packages(['xmlsec1','python-pysaml2'], {
    ensure        => $package_ensure,
    allow_virtual => true,
    tag           => 'keystone-support-package',
  })

  keystone_config {
    'saml/certfile':                      value => $certfile;
    'saml/keyfile':                       value => $keyfile;
    'saml/idp_entity_id':                 value => $idp_entity_id;
    'saml/idp_sso_endpoint':              value => $idp_sso_endpoint;
    'saml/idp_metadata_path':             value => $idp_metadata_path;
    'saml/idp_organization_name':         value => $idp_organization_name;
    'saml/idp_organization_display_name': value => $idp_organization_display_name;
    'saml/idp_organization_url':          value => $idp_organization_url;
    'saml/idp_contact_company':           value => $idp_contact_company;
    'saml/idp_contact_name':              value => $idp_contact_name;
    'saml/idp_contact_surname':           value => $idp_contact_surname;
    'saml/idp_contact_email':             value => $idp_contact_email;
    'saml/idp_contact_telephone':         value => $idp_contact_telephone;
  }

  if $idp_contact_type and !($idp_contact_type in ['technical','support','administrative','billing','other']) {
    fail('Allowed values for idp_contact_type are: technical, support, administrative, billing and other')
  } else{
    keystone_config {
      'saml/idp_contact_type': value => $idp_contact_type;
    }
  }

  exec {'saml_idp_metadata':
    path      => '/usr/bin',
    user      => "${user}",
    command   => "keystone-manage saml_idp_metadata > ${idp_metadata_path}",
    creates   => $idp_metadata_path,
    subscribe => Anchor['keystone::config::end'],
    notify    => Anchor['keystone::service::end'],
    tag       => 'keystone-exec',
  }

  file { $idp_metadata_path:
    ensure => present,
    mode   => '0600',
    owner  => "${user}",
  }

}
