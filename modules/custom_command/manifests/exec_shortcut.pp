# -*- mode: puppet -*-
# vi: set ft=puppet :
define custom_command::exec_shortcut  (
  $link_basename  = $title,
  $link_pathname  = '$HOME\Desktop',
  $target_path    = undef,
  $target_args    = undef,
  $target_workdir = undef,
  $link_desc      = undef,
  $icon_location  = undef,
  $run_as_admin   = undef,
  $debug          = false,
  $version        = '0.3.0'
)   {
  # Validate install parameters
  validate_string($link_basename )
  validate_string($link_pathname )
  validate_string($target_path )
  validate_string($target_args )
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $title_tag = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${title_tag}"
  $log = "${log_dir}\\${title_tag}.${random}.log"
  if ( $link_pathname == ''){
    $link_pathname = '$HOME\Desktop'
  }
  $expression = "test-path -path ('{0}\\{1}.lnk' -f \"${link_pathname}\", '${link_basename}')"
  # convert Powershell (True, False) to shess exit codes (0,1)
  $path_check = "exit [int]( -not (${expression}))"
  if ($run_as_admin ) {
    $template = 'create_admin_shortcut_ps1.erb'
  } else {
    $template = 'create_simple_shortcut_ps1.erb'
  }
  # NOTE: for creating shortcuts to powershell scripts
  # one need to set TargetPath to simply
  # 'c:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
  # and have Arguments set to
  # '-executionpolicy remotesigned -noprofile ' + $target_script_path
  exec { "${title_tag}_create_shortcut":
    command   => template("custom_command/${template}"),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => $path_check,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }
  if $debug {
    # see: https://www.tek-tips.com/viewthread.cfm?qid=850335
    # one should "re-create" an existing link again to get to the preperties
    # e.g.
    # $o = new-object -ComObject 'WScript.Shell'
    # $s = $o.CreateShortcut("C:\Users\Serguei\Desktop\Downloads - Shortcut.lnk")
    # re-create an existing link again to get to the properties.
    # write-output $s.TargetPath
    # gives
    # C:\Users\Serguei\Downloads
    exec { "${tasl_title_tag}_confirm_shortcut_created":
      command   => $path_check,
      cwd       => 'c:\windows\temp',
      logoutput => true,
      provider  => 'powershell',
      require   => Exec [ "${title_tag}_create_shortcut"],
      command   => template("custom_command/${template}"),
      cwd       => 'c:\windows\temp',
      logoutput => true,
      path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
      provider  => 'powershell',
    }
  }
}

