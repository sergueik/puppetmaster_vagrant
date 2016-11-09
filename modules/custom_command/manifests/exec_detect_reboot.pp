# -*- mode: puppet -*-
# vi: set ft=puppet :
define custom_command::exec_detect_reboot  (
  $debug          = false,
  $verbose        = false,
  $version        = '0.3.0'
)   {
  # Validate install parameters
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $title_tag = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${title_tag}"
  $log = "${log_dir}\\${title_tag}.${random}.log"

  template = 'get_pending_reboot_ps1.erb'
  # runs https://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542
  # (in general any workflow element would do)
  # TODO: randomize
  $script_path = 'C:\windows\temp\script.ps1'
  # Generate runner
  file { "${title_tag} create script":
    ensure              => file,
    path                => $script_path,
    content             => template("custom_command/${template}"),
    source_permissions => ignore,
    before              =>
  }

  # NOTE: helping Powershell not slurp the exit code of invoke-expression
  $probe_command = "\$VerbosePreference = 'continue'; \$result = invoke-expression -command ${script_path} -verbose; if (\$result ) { exit 0 } else { exit 1 } "
  # NOTE: somewhat simpler if one does not care about the exit status of the script one is running
  # $probe_command  => "invoke-expression -command ${script_path}",
  $action_command = 'restart-computer -force -whatif'
  # NOTE: -timeout is a Powershell v4.0 parameter

  exec { "${title_tag} probe":
    command   => $probe_command,
    cwd       => 'c:\windows\temp',
    logoutput => true,
    # unless    => $path_check,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    notify    => Exec["$title_tag action"]
  }
  exec { "$title_tag action":
    command     => $action_command,
    refreshonly => true,
    cwd         => 'c:\windows\temp',
    logoutput  => true,
    provider   => 'powershell',
    require    => Exec ["${title_tag} probe"],
    path       => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider   => 'powershell',
  }
}
