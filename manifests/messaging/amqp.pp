# Class keystone::messaging::amqp
#
# keystone messaging configuration
#
# == Parameters
#
# [*amqp_pre_settled*]
#   (Optional) Send messages of this type pre-settled
#   Defaults to $facts['os_service_default'].
#
# [*amqp_idle_timeout*]
#   (Optional) Timeout for inactive connections
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_ca_file*]
#   (Optional) CA certificate PEM file to verify server certificate
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_cert_file*]
#   (Optional) Identifying certificate PEM file to present to clients
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_key_file*]
#   (Optional) Private key PEM file used to sign cert_file certificate
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $facts['os_service_default'].
#
# [*amqp_sasl_mechanisms*]
#   (Optional) Space separated list of acceptable SASL mechanisms
#   Defaults to $facts['os_service_default'].
#
class keystone::messaging::amqp(
  $amqp_pre_settled                     = $facts['os_service_default'],
  $amqp_idle_timeout                    = $facts['os_service_default'],
  $amqp_ssl_ca_file                     = $facts['os_service_default'],
  $amqp_ssl_cert_file                   = $facts['os_service_default'],
  $amqp_ssl_key_file                    = $facts['os_service_default'],
  $amqp_ssl_key_password                = $facts['os_service_default'],
  $amqp_sasl_mechanisms                 = $facts['os_service_default'],
) {

  include keystone::deps

  oslo::messaging::amqp { 'keystone_config':
    pre_settled      => $amqp_pre_settled,
    idle_timeout     => $amqp_idle_timeout,
    ssl_ca_file      => $amqp_ssl_ca_file,
    ssl_cert_file    => $amqp_ssl_cert_file,
    ssl_key_file     => $amqp_ssl_key_file,
    ssl_key_password => $amqp_ssl_key_password,
    sasl_mechanisms  => $amqp_sasl_mechanisms,
  }

}
