require_relative '../windows_spec_helper'


context 'Administrators' do

  # based on: http://poshcode.org/6581
  # NOTE - in the cloud production environment 
  # the wmi call may take a **very** long time effectively hanging the process, making it inpractical.

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
            write-output $matches[1]
          }
        }
      }
      Get-LocalGroupMembers '#{local_group}'
      EOF
    ) do
      {
        'Administrator' => true,
        'Domain Admins' => false,
      }.each do |key,val|
        if val
          its(:stdout) { should contain key }
        end
      end
    end
  end

  # based on: http://poshcode.org/544
  context 'ADSI' do
    domain_groups = []

    describe command(<<-EOF

      $DomainGroups = @()
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
            write-output $_.Exception.Message
          }
        }
        write-output $MemberNames
        if ($DomainGroups.count) {
          $DomainGroups | ForEach-Object {
            $output = '' | Select-Object Server,Group,InLocalAdmin
            $output.Server = $Server
            $output.Group = $_
            $output.InLocalAdmin = $MemberNames -contains $_
            write-output $output
          }
        }
      }
    EOF
    ) do
      {
        'Domain Admins' => true,
        'Administrator' => false,
      }.each do |key,val|
        if val
          its(:stdout) { should contain key }
        end
      end
    end
  end
end
