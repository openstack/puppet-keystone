#
# Class to manage and secure the keystone-paste.ini pipeline configuration.
#
# DEPRECATED!
#
# The keystone module uses the admin_token parameter in keystone.conf to
# bootstrap the basic setup of an admin user, project, and domain. However, the
# admin_token provides an easy vector of attack for production keystone
# installations. Including this class will remove the admin_token_auth
# from the paste pipeline to improve security. After this class is run,
# future puppet runs must have an openrc file with valid keystone v3
# admin credentials in /root/openrc available, or else must be run with
# valid keystone v3 credentials set as environment variables.
#
class keystone::disable_admin_token_auth {

  warning('keystone::disable_admin_token_auth is deprecated, has no effect and will be removed in a later release')
}
