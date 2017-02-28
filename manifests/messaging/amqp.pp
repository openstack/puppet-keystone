# Class keystone::messaging::amqp
#
# keystone messaging configuration
#
# == Parameters
#
# [*amqp_pre_settled*]
#   (Optional) Send messages of this type pre-settled
#   Defaults to $::os_service_default.
#
# [*amqp_idle_timeout*]
#   (Optional) Timeout for inactive connections
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_ca_file*]
#   (Optional) CA certificate PEM file to verify server certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_cert_file*]
#   (Optional) Identifying certificate PEM file to present to clients
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_file*]
#   (Optional) Private key PEM file used to sign cert_file certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $::os_service_default.
#
# [*amqp_allow_insecure_clients*]
#   (Optional) Accept clients using either SSL or plain TCP
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_mechanisms*]
#   (Optional) Space separated list of acceptable SASL mechanisms
#   Defaults to $::os_service_default.
#
class keystone::messaging::amqp(
  $amqp_pre_settled                     = $::os_service_default,
  $amqp_idle_timeout                    = $::os_service_default,
  $amqp_ssl_ca_file                     = $::os_service_default,
  $amqp_ssl_cert_file                   = $::os_service_default,
  $amqp_ssl_key_file                    = $::os_service_default,
  $amqp_ssl_key_password                = $::os_service_default,
  $amqp_allow_insecure_clients          = $::os_service_default,
  $amqp_sasl_mechanisms                 = $::os_service_default,
) {

  include ::keystone::deps

  oslo::messaging::amqp { 'keystone_config':
    pre_settled            => $amqp_pre_settled,
    idle_timeout           => $amqp_idle_timeout,
    ssl_ca_file            => $amqp_ssl_ca_file,
    ssl_cert_file          => $amqp_ssl_cert_file,
    ssl_key_file           => $amqp_ssl_key_file,
    ssl_key_password       => $amqp_ssl_key_password,
    allow_insecure_clients => $amqp_allow_insecure_clients,
    sasl_mechanisms        => $amqp_sasl_mechanisms,
  }

}
