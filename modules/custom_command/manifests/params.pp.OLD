# Class: custom_command::params
#
#   The Module configuration settings.
#
class custom_command::params {

  case $::osfamily {
      'windows': {
      $version          = '0.1.0'
      $base_version     = regsubst($version,'^(.*)-\d$','\1')
    }

   default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
}
  $enable = true
  $config = 'unused'

}
