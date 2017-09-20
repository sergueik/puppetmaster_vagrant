# this custom type handles 
# removal of catalina_home directories from the downlefel installations 
# when the custom tomcat rpm ceases to do sthe same

def custom_command::catalina_cleanup(
  String  $catalina_home       = '/opt/tomcat',
  String  $tomcat_package_name = 'tomcat7',
  String  $tomcat_package_version = '7.0.51',
  Boolean $debug = false,
) {

 # only do cleanup of side by side installations if installed
 if ($debug) {
    # custom version implemented as an exec
    exec { "check the installed versions of ${tomcat_package_name}":
      command => "rpm --queryformat '%{V}' -q '${tomcat_package_name}' | grep -v 'not installed' |grep -vq '${tomcat_package_version}'",
      returns => [0,1],
      path    => '/bin:/usr/bin',
      logoutput => true,
      before  => Exec["cleanup of side by side ${tomcat_package_name} installations found in ${catalina_home_parent}"],
  }

  $catalina_home_parent = regsubst($catalina_home, '/[^/]+$', '')  
  exec { "cleanup of side by side ${tomcat_package_name} installations found in ${catalina_home_parent}":    
    command   => "cd ${catalina_home_parent} && find . -type d -maxdepth 1 -exec rm -rf {} \\;",
    path      => '/bin:/usr/bin',
    logoutput => true,
    onlyif    => "rpm --queryformat '%{V}' -q '${tomcat_package_name}' | grep -v 'not installed' | grep -vq '${tomcat_package_version}'",
    before    => Class['::tomcat'],
  }
}
