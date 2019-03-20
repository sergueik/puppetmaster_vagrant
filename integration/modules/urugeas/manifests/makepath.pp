# -*- mode: puppet -*-
# vi: set ft=puppet :

define urugeas::makepath (
  String $target_path = lookup('urugeas::target_path'),
  Boolean $debug      = false,
  String $version     = '0.1.0'
) {

  validate_string($target_path)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $array_dirs = split($target_path, '/')
  if $debug {
    notify {"${taskname}: array dirs size = ${array_dirs.size}": }
  }
  $subdirs1 = flatten($array_dirs.map|Integer $index1,String $value1| {
    $subdir = join(flatten(
    $array_dirs.map|Integer $index2,String $value2| {
      if $index2 <= $index1 {
        if $debug {
          notify {"${taskname}: using ${index2} for ${index1}":}
	}
	$value2
      }
    }),'/')
    if $debug {
      notify {"${taskname}: subdir : ${subdir}": }
      # will produce:
      #
      #  Notice: subdir : /undef/undef/undef/undef
      #  Notice: subdir : /var/undef/undef/undef
      #  Notice: subdir : /var/www/undef/undef
      #  Notice: subdir : /var/www/html/undef
      #  Notice: subdir : /var/www/html/jenkins
    }
    $subdir
  })
  if $debug {
    notify {"${taskname}: subdirs1 : ${subdirs1}": }
  }
  $subdirs2 = $subdirs1.map |$path| { regsubst($path, '/undef', '', 'G') }
  if $debug {
    notify {"s${taskname}: ubdirs2 : ${subdirs2}": }
  }
  $subdirs = $subdirs2.filter |$dir| { $dir =~ /[a-z]/ }
  notify {"${taskname}: subdirs : ${subdirs}": }
  $subdirs.each |String $subdir_path| {
    notify {"${taskname}: making directory : ${subdir_path}": }
#    ensure_resource ('file' , $subdir_path, {
#      ensure => directory,
#      mode   => '0775',
#      owner  => root,
#      group  => root,
#    })
  }
  $subdirs.each |String $subdir_path| {
    notify {"${taskname}: really making directory : ${subdir_path}": }
    file{ $subdir_path:
      ensure => directory,
      # TODO: handle '/var' which has special permissions
      # mode   => '0775',
      owner  => root,
      group  => root,
      force  => true
    }
  }

}
