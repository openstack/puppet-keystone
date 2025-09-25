# == Class: keystone::federation::identity_provider
#
# == Parameters
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
# [*certfile*]
#   (Optional) Path of the certfile for SAML signing. The path can not
#   contain a comma. (string value).
#   Defaults to $facts['os_service_default'].
#
# [*keyfile*]
#   (Optional) Path of the keyfile for SAML signing. The path can not
#   contain a comma (string value).
#   Defaults to $facts['os_service_default'].
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
#  Defaults to $keystone::params::user.
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
class keystone::federation::identity_provider (
  $idp_entity_id,
  $idp_sso_endpoint,
  Stdlib::Absolutepath $idp_metadata_path,
  $certfile                               = $facts['os_service_default'],
  $keyfile                                = $facts['os_service_default'],
  $user                                   = $keystone::params::user,
  $idp_organization_name                  = $facts['os_service_default'],
  $idp_organization_display_name          = $facts['os_service_default'],
  $idp_organization_url                   = $facts['os_service_default'],
  $idp_contact_company                    = $facts['os_service_default'],
  $idp_contact_name                       = $facts['os_service_default'],
  $idp_contact_surname                    = $facts['os_service_default'],
  $idp_contact_email                      = $facts['os_service_default'],
  $idp_contact_telephone                  = $facts['os_service_default'],
  $idp_contact_type                       = $facts['os_service_default'],
  Stdlib::Ensure::Package $package_ensure = present,
) inherits keystone::params {
  include keystone::deps

  if $keystone::service_name != 'httpd' {
    fail ('Keystone need to be running under Apache for Federation work.')
  }

  package { 'xmlsec1':
    ensure => $package_ensure,
    tag    => 'keystone-support-package',
  }

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

  if (is_service_default($idp_contact_type) or
      ($idp_contact_type in ['technical','support','administrative','billing','other'])) {
    keystone_config {
      'saml/idp_contact_type': value => $idp_contact_type;
    }
  } else {
    fail('Allowed values for idp_contact_type are: technical, support, administrative, billing and other')
  }

  exec { 'saml_idp_metadata':
    path      => '/usr/bin',
    user      => $user,
    command   => "keystone-manage saml_idp_metadata > ${idp_metadata_path}",
    creates   => $idp_metadata_path,
    subscribe => Anchor['keystone::config::end'],
    notify    => Anchor['keystone::service::end'],
    tag       => 'keystone-exec',
  }

  file { $idp_metadata_path:
    ensure => file,
    mode   => '0600',
    owner  => $user,
  }
}
