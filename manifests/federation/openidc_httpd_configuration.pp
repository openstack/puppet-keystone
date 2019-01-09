# == define: keystone::federation::openidc_httpd_configuration
#
# DEPRECATED!
#
# == Parameters
#
# [*keystone_endpoint*]
#  The keystone endpoint to use when configuring the OpenIDC redirect back
#  to keystone
#  (Required) String value.
#
define keystone::federation::openidc_httpd_configuration (
  $keystone_endpoint = undef
) {

  warning('keystone::federation::openidc_httpd_configuration is deprecated')
}
