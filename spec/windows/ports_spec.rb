require_relative '../windows_spec_helper'
context 'ports' do
      @executable =  'svchost' 
    describe command(<<-END_COMMAND
    \$process_id = (get-wmiobject -computername '.' -query "select name, processid from win32_process where name like '#{@executable}%'").processid
$status  = -1
$listening_ports = @()
`c:\\windows\\system32\\netstat.exe -ano -p TCP` |
foreach-object { $fields = ($_ -replace ' ' , '/') -split '/' 
$listening_process_id = $fields[-1]
$listening_socket = $fields[2]
if ($listening_process_id -eq $process_id) {
  $status  = 0
  $listening_ports+= ($listening_socket -replace '[\\d.]+:', '')
 }
} 
write-output ($listening_ports -join ',')
return $status
END_COMMAND
) do
      its(:stdout) { should match /([\d],?)+/ }
      its(:exit_status) { should == 0 } 
    end
end
