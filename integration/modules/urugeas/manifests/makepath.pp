# -*- mode: puppet -*-
# vi: set ft=puppet :
# this module to some extent re-invents the
# https://puppet.com/docs/puppet/5.0/lang_relationships.html#auto-relationships
define urugeas::makepath (
  String $target  = lookup('urugeas::target'),
  Boolean $debug  = false,
  String $version = '0.3.0'
) {

  validate_string($target)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $array_dirs = split($target, '/')
  $subdirs_tmp1 = flatten($array_dirs.map|Integer $index1,String $value1| {
    $subdir = join(flatten(
    $array_dirs.map|Integer $index2,String $value2| {
      if $index2 <= $index1 {
	$value2
      }
    }),'/')
    $subdir
  })
  $subdirs_tmp2 = $subdirs_tmp1.map |$path| { regsubst($path, '/undef', '', 'G') }
  $subdirs = $subdirs_tmp2.filter |$dir| { $dir =~ /[a-z-0-9]/ }
  if $debug {
    notify {"${taskname}: subdirs : ${subdirs}": }
  }
  if $debug {
    $subdirs.each |String $subdir_path| {
      notify {"${taskname}: about to be making directory : ${subdir_path}": }
    }
  }
  $subdirs.each |String $subdir_path| {
   if $subdir_path !~ /^\/(?:var|usr|tmp|opt|home)$/ {
      file{ $subdir_path:
        ensure => directory,
        # TODO: handle '/var' which has special permissions
        # mode   => '0775',
        owner  => root,
        group  => root,
        force  => true
      }
    #  ensure_resource ('file' , $subdir_path, {
    #    ensure => directory,
    #    mode   => '0775',
    #    owner  => root,
    #    group  => root,
    #  })
       -> notify {"${taskname}: really just made directory : ${subdir_path}": }
     }
  }
}
