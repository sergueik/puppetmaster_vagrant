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
    tcp_port = 3702
    timeout  = 100
  # origin http://poshcode.org/5310,  only TCP  part so far
  tcp_port = 8100
  timeout = 1000
  # retry is a reserved language word
  # the code below does not loop yet.
  retries = 10
  describe command(<<-END_COMMAND
    $ErrorActionPreference = 'SilentlyContinue'
    $tcpobject = new-Object system.Net.Sockets.TcpClient
    $port = #{tcp_port}
    $timeout = #{timeout}
    $connect = $tcpobject.BeginConnect('127.0.0.1',$port,$null,$null)
    $status = $connect.AsyncWaitHandle.WaitOne($timeout,$false)
    if( -not $status ) {
       $tcpobject.Close()
       write-output "Connection to Port ${port} Timed Out"
    } else {
     $tcpobject.EndConnect($connect) | out-Null
     write-output "Connection to Port ${port} was successful"
    }
    $tcpobject.Close()
    END_COMMAND
  )  do
      its(:stdout) { should match /successful/ }
      its(:exit_status) { should == 0 } 
  end  

  describe retry_port(8100) do
    it { should be_listening.with_retry(30) }
  end

  # basic fixed port  script 
   
  describe command(<<-EOF
    $retries = #{retries}
    $port = #{tcp_port}
    0.. $retries | foreach-object { 
    $x = & "netstat" "-ano"
    $count = @($x |  where-object {$_ -match ":${Port}" }).count
      if  ($count -ne 0 )  { 
        write-output "Port ${port} is listening"
        exit 0
      } else { 
        write-output "No access to port ${port}"
        start-sleep -seconds 30 
      }
    }
  EOF
  ) do
    its (:stdout) { should match 'listening' }
  end
