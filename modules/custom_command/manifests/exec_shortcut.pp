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
    # https://docs.microsoft.com/en-us/windows/desktop/shell/shellfolderitem-extendedproperty
    # (new-object -ComObject 'Shell.Application').NameSpace(0).ParseName("${env:userprofile}\Desktop\Downloads - Shortcut.lnk").ExtendedProperty('Link Target')
    # Tosee all defined properties of ShellFolderItem, use snippet from
    # https://jamesone111.wordpress.com/2008/12/09/borrowing-from-windows-explorer-in-powershell-part-2-extended-properties/
    # $objShell = New-Object -ComObject Shell.Application
    # $objFolder = $objShell.namespace("${env:userprofile}\Desktop")
    # 0..266 | foreach {'{0,3}:{1}'-f $_,$objFolder.getDetailsOf($Null, $_)}
    # will give:
    # 194:Link target
    # The returned value will be a path e.g. 'c:\windows\system32' or a shell namespace e.g. 'Desktop'
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
