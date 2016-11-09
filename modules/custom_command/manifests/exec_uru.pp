# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_uru(
  $toolspath = 'c:\tools',
  $version   = '0.4.0',
  $debug     = $false
 ) {
  validate_string($toolspath)
  validate_bool($debug)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $report_dir = "c:\\temp\\${taskname}"
  $script_path = "${report_dir}\\uru_launcher.ps1"
  $report_log = "${log_dir}\\${script}.${random}.log"

  exec { "purge ${report_dir}":
    cwd       => 'c:\windows\temp',
    command   => "\$target='${report_dir}' ; remove-item -recurse -force -literalpath \$target",
    logoutput => true,
    onlyif    => "\$target='${report_dir}' ; if (-not (test-path -literalpath \$target)){exit 1}",
    provider  => 'powershell',
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
  }
  ensure_resource('file', 'c:/temp' , { ensure => directory } )

  ensure_resource('file', $report_dir , {
    ensure => directory,
    require => Exec["purge ${report_dir}"],
  })

  file { "${name} Rakefile":
    ensure             => file,
    path               => "${toolspath}/Rakefile",
    content            => template('custom_command/Rakefile_serverspec.erb'),
    source_permissions => ignore,
  } ->

  file { "${toolspath}/spec":
    ensure             => directory,
    source_permissions => ignore,
  } ->

  file { "${toolspath}/spec/${name}":
    ensure             => directory,
    source_permissions => ignore,
  } ->

  # Populate the serverspec directory from all covered modules
  # to scan multiple paths per module, build array ourside of the file resource:
  # e.g.
  # $serverspec_directories = unique(flatten([$covered_modules.map |$item| { "${item}/serverspec/${osfamily_platform_directory}" }, $covered_modules.map |$item| { "${item}/serverspec/${::osfamily}" }]))
  # May also need to provide a custom mount point through `fileserver.conf
  # https://docs.puppet.com/puppet/latest/reference/file_serving.html
  # to enable globbing serverspec files by role/ profile
  # [<NAME OF MOUNT POINT>]
  # path <PATH TO DIRECTORY>
  # allow *
  file { "${toolspath}/spec/multiple":
    ensure             => directory,
    path               => "${root}/spec/serverspec",
    recurse            => true,
    source             => $covered_modules.map |$item| { "puppet:///modules/${item}/serverspec/${::osfamily}" },
    source_permissions => ignore,
    sourceselect       => all,
  }

  file { "${name} windows_spec_helper.rb":
    ensure             => file,
    path               => "${toolspath}/spec/windows_spec_helper.rb",
    content            => template('custom_command/windows_spec_helper_rb.erb'),
    source_permissions => ignore,
  }

  case $::osfamily {
    'windows': {
      file { "${name} launcher script":
        ensure             => file,
        path               => $script_path,
        content            => template('custom_command/uru_runner_ps1.erb'),
        source_permissions => ignore,
      }
      exec { "Execute uru ${name}":
        command     => "powershell.exe -executionpolicy remotesigned -file ${script_path}",
        require     => File[ "${name} launcher script"],
        path        => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
        provider    => 'powershell',
        refreshonly => true,
        subscribe   => File["${toolspath}/spec/multiple"],
        require     => File["${name} launcher script"],
        logoutput   => true,
      } ->

      exec { "Log serverspec summary ${name}":
        command     => "type ${toolspath}\\reports\\report_.json",
        path        => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
        provider    => 'powershell',
        refreshonly => true,
        subscribe   => Exec["Execute uru ${name}"],
        logoutput   => true,
      }
    }
    default: {
      file { "${name} launcher script":
        ensure  => file,
        path    => $script_path,
        content => regsubst(template('custom_command/uru_runner_sh.erb'), "\r\n", "\n", 'G')',
        mode    => '0755',
      }
    }
  }

  if $debug {
    notify { "Done ${name}.":,
      require=> Exec["Log serverspec summary ${name}"],
    }
  }
}
