# This class can be used to create a file
#
# @example when declaring the apache class
#  class { '::profiles::bootstrap::fail2ban': }
#
# @param services Services to control.
class profiles::bootstrap::file (
) {
  file { '/tmp/file':
    ensure => file,
    content => 'This is a file'
  }
}
