require_relative '../windows_spec_helper'


context 'Administrators' do

  # origin: http://poshcode.org/6581
  context 'WMI' do
    local_group = 'Administrators'
    describe command(<<-EOF
      function Get-LocalGroupMembers {
        param(
          [string]$LocalGroup = 'Administrators'
        )
        $pattern = ('*Name="{0}"' -f $LocalGroup)
        foreach ($user in (Get-WmiObject -Class 'win32_groupuser' | Where-Object { $_.GroupComponent -like $pattern })) {
          if ($user.PartComponent -match 'Name="([^"]+)"') {
            Write-Output $matches[1]
          }
        }
      }
      Get-LocalGroupMembers #  '#{local_group}'
      EOF
    ) do
      {
        'Administrator' => true,
        'Domain Admins' =>  false,
        'Other Group'  => false,
      }.each do |key,val|
        if val
          its(:stdout) { should match /#{key}/io }
        end  
      end
    end 
  end

  # origin: http://poshcode.org/544
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
