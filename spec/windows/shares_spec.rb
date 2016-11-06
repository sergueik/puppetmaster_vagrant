require_relative '../windows_spec_helper'

context 'Windows Shares' do

  # origin:
  # http://www.cyberforum.ru/powershell/thread1706478.html
  # http://etutorials.org/Server+Administration/Active+directory/Part+III+Scripting+Active+Directory+with+ADSI+ADO+and+WMI/Chapter+22.+Manipulating+Persistent+and+Dynamic+Objects/22.3+Enumerating+Sessions+and+Resources/
  # http://www.vistax64.com/powershell/172091-get-open-file-sessions.html
  # https://social.technet.microsoft.com/Forums/windowsserver/en-US/2f606c18-4fc9-4ba9-bc55-77173d42c058/using-lanmanserver-with-powershell?forum=winserverpowershell
  describe command(<<-EOF
    $computer = $env:computername
    $results = @()
    $shared_resources = [adsi]"WinNT://${computer}/LanmanServer"
    $shared_resources.Invoke('Resources') | ForEach-Object {
      try {
        $results += New-Object PsObject -Property @{
          Id = $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)
          itemPath = $_.GetType().InvokeMember('Path', 'GetProperty', $null, $_, $null)
          UserName = $_.GetType().InvokeMember('User', 'GetProperty', $null, $_, $null)
          LockCount = $_.GetType().InvokeMember('LockCount', 'GetProperty', $null, $_, $null)
          Server = $computer
        }
      }
      catch {
        Write-Warning $error[0]
      }
    }
    $results
  EOF
  ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match( /<list of shares>/i ) }
  end
end