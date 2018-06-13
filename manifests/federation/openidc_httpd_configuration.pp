# == define: keystone::federation::openidc_httpd_configuration  [70/1473]
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
  concat::fragment { "configure_openidc_on_${title}":
    target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_${title}.conf",
    content => template('keystone/openidc.conf.erb'),
    order   => $keystone::federation::openidc::template_order,
  }
}
