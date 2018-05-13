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
  # origin: https://docs.microsoft.com/en-us/powershell/module/smbshare/get-smbshare?view=win10-ps
  # https://github.com/karmafeast/windows_smb/blob/master/manifests/manage_smb_share.pp
  # for registry configuration details see
  # https://github.com/karmafeast/windows_smb/blob/master/manifests/manage_smb_server_config.pp
  # https://github.com/karmafeast/windows_smb/blob/master/manifests/manage_smb_client_config.pp 
  # Windows Server 2012, server service enabled and running
  # NOTE: can get shares that are connected to a specific server, via $scopename
  share_name = 'temp'
  scope_name = '*'
  describe command(<<-EOF
    $share_name = '#{share_name}'
    $scope_name = '#{scope_name}'
    if ($scope_name -eq '' ) {
      $scope_name = '*'
    }
    $computer = $env:computername
    get-smbshare -name $share_name -scopeName $scope_name | format-list -property *

    EOF
  ) do
      its(:exit_status) { should eq 0 }
      # NOTE: Preparing modules for first use error
      {'path' => 'c:\\temp'}.each do |key,value|
        its (:stdout) { should match(Regexp.new( "#{key} * : *" + Regexp.escape(value), Regexp.IRNORECASE)) }
    end
  end
end
