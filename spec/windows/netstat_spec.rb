require_relative '../windows_spec_helper'
context 'Inspecting Netstat' do
  # The command below is the equivalent of a linux shell command
  # ps -p $(sudo netstat -oanpt | grep $connected_port|awk '{print $7}' | sed 's|/.*||')
  describe command (<<-EOF 
$netstat_output = invoke-expression -command "cmd.exe /c netstat -ano -p TCP" ;
$connected_port = 1521
$oracle_port_listening_pid = (
$netstat_output |
  where-object  { $_ -match ":${connected_port}" } | 
    select-object -first 1 | 
      foreach-object { $fields = $_.split(" ") ; write-output ('{0}' -f $fields[-1]) })

$oracle_port_listening_pid
$oracle_port_listening_process = get-CIMInstance win32_process | where-object { $_.Processid -eq  $oracle_port_listening_pid}

write-output  $oracle_port_listening_process.commandLine

EOF
) do
    its(:stdout) { should match /TNSLSNR/io }
  end

end
