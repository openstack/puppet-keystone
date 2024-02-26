type Keystone::PublicEndpointUrl = Variant[
  Stdlib::HTTPUrl,
  # NOTE(tkajinam): This is required by Zaqar
  Pattern[/(?i:\Awss?:\/\/.*\z)/],
]
