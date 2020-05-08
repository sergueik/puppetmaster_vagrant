# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command:: exec_attribute_fix(
  $version         = '0.1.0'
) {
   # useful ito have file attribute fixups in one place
   # e.g. when vendor package sets the file attrbutes
   # in a non-compliant fashion

   # fix the world accessible files
   $apply_attr_command = 'find -type f -and \( -perm /o=w -or -perm /o=x -or -perm -o=r\) -exec chmod o-wxr {} \;'
   # count offending files
   $no_wrong_attr_command = 'test $(find -type f -and \( -perm /o=w -or -perm /o=x -or -perm -o=r\) | wc -l) -eq 0'

  # Run command to fix file attributes
  exec { 'Clear world-accessible files':
    command     => $apply_attr_command,
    cwd         => $base_path,
    unless      => $no_wrong_attr_command,
    provider    => shell,
    refreshonly => true,
    logoutput   => on_failure,
    returns     => [0,1],
    # subscribe   => Package[$package_name],
    $ to suppress
    # creates     => "${toolspath}/reports/report_.json",
  }

  # NOTE: unfinished
  $apply_owner_command = "find ${base_dir} -xdev \\( -type f -or -type d \\) -and \\( \\( ! -user ${need_user} \\) -or \\( ! -group ${need_group} \\) -or -nouser -or -nogroup \\) -exec chown ${need_user}:$[need_group} {} \\;"
  $no_orphans_command = "test `find ${base_dir} -xdev \\( -type f -or -type d \\) -and \\( \\( ! -user ${need_user} \\) -or \\( ! -group ${need_group} \\) -or -nouser -or -nogroup \\) | wc -l` -eq 0 "

}
