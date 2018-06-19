# == Class: keystone::deps
#
#  keystone anchors and dependency management
#
class keystone::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'keystone::install::begin': }
  -> Package<| tag == 'keystone-package'|>
  ~> anchor { 'keystone::install::end': }
  -> anchor { 'keystone::config::begin': }
  -> Keystone_config<||>
  ~> anchor { 'keystone::config::end': }
  -> anchor { 'keystone::db::begin': }
  -> anchor { 'keystone::db::end': }
  ~> anchor { 'keystone::dbsync::begin': }
  -> anchor { 'keystone::dbsync::end': }
  ~> anchor { 'keystone::service::begin': }
  ~> Service<| tag == 'keystone-service' |>
  ~> anchor { 'keystone::service::end': }

  # all cache settings should be applied and all packages should be installed
  # before service startup
  Oslo::Cache<||> -> Anchor['keystone::service::begin']

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db<||> -> Anchor['keystone::dbsync::begin']

  # paste-api.ini config should occur in the config block also.
  Anchor['keystone::config::begin']
  -> Keystone_paste_ini<||>
  ~> Anchor['keystone::config::end']

  # policy config should occur in the config block also.
  Anchor['keystone::config::begin']
  -> Openstacklib::Policy::Base<||>
  ~> Anchor['keystone::config::end']

  # Support packages need to be installed in the install phase, but we don't
  # put them in the chain above because we don't want any false dependencies
  # between packages with the keystone-package tag and the keystone-support-package
  # tag.  Note: the package resources here will have a 'before' relationshop on
  # the keystone::install::end anchor.  The line between keystone-support-package and
  # keystone-package should be whether or not keystone services would need to be
  # restarted if the package state was changed.
  Anchor['keystone::install::begin']
  -> Package<| tag == 'keystone-support-package'|>
  -> Anchor['keystone::install::end']

  # We need openstackclient before marking service end so that keystone
  # will have clients available to create resources. This tag handles the
  # openstackclient but indirectly since the client is not available in
  # all catalogs that don't need the client class (like many spec tests)
  Package<| tag == 'openstack'|>
  ~> Anchor['keystone::service::end']

  # The following resources need to be provisioned after the service is up.
  Anchor['keystone::service::end']
  -> Keystone_domain<||>
  Anchor['keystone::service::end']
  -> Keystone_endpoint<||>
  Anchor['keystone::service::end']
  -> Keystone_role<||>
  Anchor['keystone::service::end']
  -> Keystone_service<||>
  Anchor['keystone::service::end']
  -> Keystone_tenant<||>
  Anchor['keystone::service::end']
  -> Keystone_user<||>
  Anchor['keystone::service::end']
  -> Keystone_user_role<||>

  # Installation or config changes will always restart services.
  Anchor['keystone::install::end'] ~> Anchor['keystone::service::begin']
  Anchor['keystone::config::end']  ~> Anchor['keystone::service::begin']

  # Install the package before the Apache module purges wsgi-keystone.conf.
  # Otherwise, the run isn't indempotent.
  Package<| tag == 'keystone-package'|> -> File<| title == '/etc/apache2/sites-enabled' |>
  Package<| tag == 'keystone-package'|> -> File<| title == '/etc/apache2/sites-available' |>
}
