
# This fragment is helpful for local Vagrant development for Windows staging / package pipeline
# The goal is to abort the Puppet run right away instead of a failing with exec exceed timeout error later
$file_path = 'c:\programdata\staging\git\git.exe' 
$file_size = 34195664


$truncation_probing_script =        "\$file_path = '${file_path}'; \$file_size = '${file_size}'; \$status = \$false ; \$status = (test-path -path \$file_path); if (\$status ) { \$status = ((get-item -path \$file_path ).Length -eq \$file_size )}; <# convert status to exitcode #> \$exitcode = [int](-not (\$status)) ; write-Output \"Will exit with \${exitcode}\" ; exit \$exitcode ;"
notify { $truncation_probing_script :

  }
exec { 'test':
  command    => $truncation_probing_script,
  path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
  provider  => 'powershell',
  logoutput => true,
  returns   => [0,1],
  before    => Package['git'],
  require   => Staging::File['git.exe'],
}

exec { "fail if ${file_path} is missing or truncated" :
  command   => "write-output \"The ${file_path} is missing or truncated. Aborting\"; exit 1",
  path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
  provider  => 'powershell',
  logoutput => true,
  unless    => $truncation_probing_script,
  before    => Package['git'],
  require   => Staging::File['git.exe'],
}

