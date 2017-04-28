# -*- mode: puppet -*-
# vi: set ft=puppet :
define custom_command::exec_remove_file  (
  $file_path = 'C:/Program files/Puppet/Agent/Data/curl.crt', # non-existent file is
  $debug     = false,
  $version   = '0.1.0'
)   {
  # Validate input parameters
  validate_string($file_path )
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $command = @(EOF)
    $target_path = '<%= $file_path %>' ;
    remove-item -force $target_path;
  | EOF

  $onlyif = @(EOF)
    $target_path = '<%= $file_path %>' ;
    write-output "target_path=${target_path}";
    $status = (test-path -path $target_path -erroraction 'SilentlyContinue' ) ;
    write-output "DEBUG: test-path ${target_path} => ${status}";
    $exitcode  =  [int]( -not ($status));
    write-output "will exit with ${exitcode}";
    exit $exitcode;
  | EOF
  exec { "${title} removing '${file_path}'":
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    command   => inline_epp(regsubst($command,"\r?\n", '', 'G')),
    onlyif    => inline_epp(regsubst($onlyif,"\r?\n", '', 'G')),
    provider  => 'powershell',
    logoutput => true,
  }
  # EPP not working, keeping draft for future ideas.
  $powershell_command_bad_example = @(EOF)
  $target_path = '<%= $file_path %>' ;
  remove-item -force $target_path;
  | EOF

  # Does not get escaped properly 
  $command_bad_example  = @(EOF)
  powershell.exe -Command \"
  <%= $powershell_command_bad_example %>
  \"
  | EOF

  exec { "${title} removing '${cert_file}', take 2":
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    command   => "powershell.exe -Command \"\$target_path = '${file_path}'; remove-item -force \$target_path;\"", 
    onlyif    => "powershell.exe -Command \"\$target_path = '${file_path}'; write-output \"target_path=\${target_path}\"; \$status = (test-path -path \$target_path -erroraction 'SilentlyContinue');  write-output \"DEBUG: test-path \${target_path} => \${status}\";  \$exitcode = [int]( -not (\$status)); write-output \"will exit with \${exitcode}\";  exit \$exitcode;\"",
    # EPP not working
    # command   => inline_epp(regsubst($command,"\r?\n", '', 'G')),
    # onlyif    => inline_epp(regsubst($onlyif,"\r?\n", '', 'G')),
    provider  => 'windows',
    logoutput => true,
  }

}
