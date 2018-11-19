# Class to disable the Keystone v2.0 API via keystone-paste.ini.
#
# DEPRECATED!
#
# This class removes the /v2.0 entries for Keystone, ensuring that the
# only supported API's are v3. After this class is executed, the
# standard overcloudrc file will no longer work, the user needs to
# utilise the overcloudrc.v3 openrc file, or alternatively the clients
# must be using valid keystone v3 credentials set as environment variables.
#

class keystone::disable_v2_api {

  warning('keystone::disable_v2_api has been deprecated, has no effect and will be removed in a later release')
}
