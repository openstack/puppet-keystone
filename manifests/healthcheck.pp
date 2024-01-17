# == Class: keystone::healthcheck
#
# Configure oslo_middleware options in healthcheck section
#
# == Params
#
# [*detailed*]
#   (Optional) Show more detailed information as part of the response.
#   Defaults to $facts['os_service_default']
#
# [*backends*]
#   (Optional) Additional backends that can perform health checks and report
#   that information back as part of a request.
#   Defaults to $facts['os_service_default']
#
# [*allowed_source_ranges*]
#   (Optional) A list of network addresses to limit source ip allowed to access
#   healthcheck information.
#   Defaults to $facts['os_service_default']
#
# [*disable_by_file_path*]
#   (Optional) Check the presence of a file to determine if an application
#   is running on a port.
#   Defaults to $facts['os_service_default']
#
# [*disable_by_file_paths*]
#   (Optional) Check the presence of a file to determine if an application
#   is running on a port. Expects a "port:path" list of strings.
#   Defaults to $facts['os_service_default']
#
class keystone::healthcheck (
  $detailed              = $facts['os_service_default'],
  $backends              = $facts['os_service_default'],
  $allowed_source_ranges = $facts['os_service_default'],
  $disable_by_file_path  = $facts['os_service_default'],
  $disable_by_file_paths = $facts['os_service_default'],
) {

  include keystone::deps

  oslo::healthcheck { 'keystone_config':
    detailed              => $detailed,
    backends              => $backends,
    allowed_source_ranges => $allowed_source_ranges,
    disable_by_file_path  => $disable_by_file_path,
    disable_by_file_paths => $disable_by_file_paths,
  }
}
