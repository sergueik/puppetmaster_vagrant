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

        $domain_groups = @()
        $local_group = 'Administrators'
        $group_member_names = @()

        [System.DirectoryServices.DirectoryEntry]$group_obj = [ADSI]"WinNT://${env:computername}/${local_group},group"
        $members_obj = @( $group_obj.psbase.Invoke('Members'))
        $members_obj | ForEach-Object { $member_obj = $_
          try {
            $group_member_names += $_.GetType().InvokeMember('Name','GetProperty',$null,$member_obj,$null)
          } catch [exception]{
            Write-Output $_.Exception.Message
          }
        }
        Write-Output $group_member_names
        if ($group_member_names.count -ne 0) {
          $group_member_names | ForEach-Object {
            [string]$group_name = $_
            $output = @{
              'Server' = $server;
              'Group' = $group;
              'InLocalAdmin' = ($group_member_names -contains $group_name);
            }
            Write-Output $output
          }
        }
    EOF
    ) do
      {
        'Domain Admins' => false,
        'Administrator' => true,
      }.each do |key,val|
        if val
          its(:stdout) { should contain key }
        end
      end
    end
  end

  # based on: http://www.cyberforum.ru/powershell/thread1950301.html
  context 'ADSI, alternative syntax' do
    domain_groups = []

    describe command(<<-EOF
      $computername = $env:COMPUTERNAME
      $winnt = [ADSI]"WinNT://${computername}, Computer"

      $winnt.Children | ? { $_.schemaClassName -eq 'group'} |

      where { $_.objectsid.tostring() -eq '1 2 0 0 0 0 0 5 32 0 0 0 32 2 0 0' } |
        foreach { $_.psbase.invoke('Members') } |
          foreach {
            write-output ( $_.GetType().InvokeMember('ADspath', 'GetProperty', $null, $_, $null).Replace('WinNT://', '').split('/') | 
            select -last 2 ) -join '/'
        } 
    EOF
    ) do
      {
        'Domain Admins' => false,
        'Administrator' => true,
        'cyg_server'    => true,
      }.each do |key,val|
        if val
          its(:stdout) { should contain key }
        end
      end
    end
  end  
end
