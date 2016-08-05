# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::serverspec_aggregator (
  $covered_modules = [],
  $toolspath       = 'c:\tools',
  $version         = '0.1.0'
) {

  validate_string($toolspath)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $report_dir = "c:\\temp\\${taskname}"
  $script_path = "${report_dir}\\uru_launcher.ps1"
  $report_log = "${log_dir}\\${script}.${random}.log"

  validate_array($covered_modules)

  $tool_product_name = 'uru'

  case $::osfamily {
  
    'RedHat': {
      $runner = 'runner.sh'
      # TODO: may need to wrap in a shell script too
      $processor = 'processor.rb'
    }

    'windows': {
      $runner = 'runner.ps1'
      $processor = 'processor.ps1'
    }
  }
    

  $runner_template = regsubst($runner, '\.', '_', 'G')
  $runner_filename = "${toolspath}/${runner}"

  $reporter_filename = "${toolspath}/${reporter}"
  $reporter_template = regsubst($reporter, '\.', '_', 'G')
  
  # Create environment
  file { 'Rakefile':
    ensure             => 'file',
    path               => "${toolspath}/Rakefile",
    source             => "puppet:///modules/${module_name}/Rakefile",
    source_permissions => 'ignore',
  } ->

  file { 'spec':
    ensure             => 'directory',
    path               => "${toolspath}/spec",
    source_permissions => 'ignore',
  } ->

  file { 'spec/spec_helper.rb':
    ensure             => 'file',
    path               => "${toolspath}/spec/spec_helper.rb",
    source             => "puppet:///modules/${module_name}/spec_helper.rb",
    source_permissions => 'ignore',
  } ->

  file { 'spec/windows_spec_helper.rb':
    ensure             => 'file',
    path               => "${toolspath}/spec/windows_spec_helper.rb",
    source             => "puppet:///modules/${module_name}/windows_spec_helper.rb",
    source_permissions => 'ignore',
  } ->

  # Populate the serverspec directory from all covered modules
  file { 'spec/serverspec':
    ensure             => directory,
    path               => "${toolspath}/spec/serverspec",
    recurse            => true,
    source             => $covered_modules.map |$item| { "puppet:///modules/${item}/serverspec/${::osfamily}" },
    source_permissions => ignore,
    sourceselect       => all,
  }
  
  case $::osfamily {
  
    'RedHat': {

      # Generate runner
      file { 'runner':
        ensure  => file,
        path    => $runner_filename,
        content => template("${module_name}/${runner_template}.erb"),
        require => [File['spec/serverspec'],File['spec/spec_helper.rb']],
        mode    => '0755',
      } ->

      # Processor for JSON report
      file { 'reporter':
        ensure             => file,
        path               => $reporter_filename,
        source             => "puppet:///modules/${module_name}/${reporter}",
        source_permissions => ignore,
        mode               => '0644',
      } ->
      
      # Run spec for everything
      exec { 'runner':
        command     => $runner_filename,
        provider    => 'shell',
        refreshonly => true,
        subscribe   => File['spec/serverspec'],
        creates     => "${toolspath}/reports/report_.json",
        logoutput   => false,
        returns     => [0,1],
      } ->

      # Process JSON report
      exec { 'reporter':
        command     => "./uru_rt admin add ruby/bin/ ; ./uru_rt ruby ${reporter_filename} --no-warnings --count 3",
        provider    => 'shell',
        cwd         => $toolspath,
        refreshonly => true,
        require     => File['reporter'],
        subscribe   => Exec['runner'],
        logoutput   => true,
      }
    }

    'windows': {

      $windows_path_scriptfile = regsubst($runner_filename, '/', '\\', 'G')

      # Generate runner
      file { 'runner':
        ensure  => file,
        path    => regsubst($runner_filename, '/', '\\', 'G'),
        content => template("${module_name}/${runner_template}.erb"),
        require => [File['spec/serverspec'],File['spec/windows_spec_helper.rb']],
      }

      # Processor for JSON report
      file { 'reporter':
        ensure             => file,
        path               => regsubst($reporter_filename, '/', '\\', 'G'),
        source             => "puppet:///modules/${module_name}/${reporter}",
        source_permissions => ignore
      } ->

      # Run spec for everything
      exec { 'runner':
        path        => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
        command     => "powershell.exe -executionpolicy remotesigned -file ${windows_path_scriptfile}",
        provider    => 'powershell',
        refreshonly => true,
        require     => File['runner'],
        subscribe   => File['spec/serverspec'],
        creates     => "${toolspath}/reports/report_.json",
        logoutput   => false,
        timeout     => 3000,
        returns     => [0,1],
      } ->

      # Process JSON report
      exec { 'reporter':
        path        => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
        cwd         => $toolspath,
        command     => "powershell.exe -executionpolicy remotesigned -file ${reporter_filename} -reports_toolspath \"${toolspath}/reports\"",
        provider    => 'powershell',
        refreshonly => true,
        require     => File['reporter'],
        subscribe   => Exec['runner'],
        logoutput   => true,
      }
    }
    default: {}
  }
}
