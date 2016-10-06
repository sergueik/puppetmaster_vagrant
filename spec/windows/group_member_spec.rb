require_relative '../windows_spec_helper'

# origin: http://poshcode.org/544

context 'Administrators' do

  context 'ADSI' do

    describe command(<<-EOF
    
      $ChildGroups = 'Domain Admins','Other Group'
      $LocalGroup = 'Administrators'

      $MemberNames = @()
      $Servers = $env:computername # for testing on local computer
      foreach ($Server in $Servers) { # accepts both [String[]] and [String]
        [System.DirectoryServices.DirectoryEntry]$Group = [adsi]"WinNT://$Server/$LocalGroup,group"
        $Members = @( $Group.psbase.Invoke('Members'))
        $Members | ForEach-Object {
          try {
            $MemberNames += $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null)
          } catch [exception]{
            # slurp
          }
        }
        $ChildGroups | ForEach-Object {
          $output = '' | Select-Object Server,Group,InLocalAdmin
          $output.Server = $Server
          $output.Group = $_
          $output.InLocalAdmin = $MemberNames -contains $_
          Write-Output $output
        }
      }
    
    EOF
    ) do
      {
        'Domain Admins' =>  false,
        'Other Group'  => false,
      }.each do |key,val|
        its(:stdout) { should match /#{key}/io }
      end
    end
  end
end
