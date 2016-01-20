context 'WMI Uptime' do
  describe command(<<-EOF
$o = Get-WmiObject -Class Win32_OperatingSystem
[DateTime] $localtime = [System.Management.ManagementDateTimeConverter]::ToDateTime( $o.LocalDateTime )
[DateTime] $lastboottime = [System.Management.ManagementDateTimeConverter]::ToDateTime( $o.LastBootUpTime )
$uptime = $localtime - $lastboottime
@(
  'Days'
  'Hours'
  'Minutes'
  'Seconds' ) |  foreach-object {
     write-output ("{0} : {1} " -f $_ ,  $uptime."$_")
  }
EOF
  ) do
    its(:stdout) { should match /Days : 0/io } 
    its(:stdout) { should match /Hours : 0/io } 
  end
end
