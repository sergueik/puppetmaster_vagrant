require_relative '../windows_spec_helper'

context 'Uptime' do
  context 'WMI' do
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
           write-output ('{0} : {1} ' -f $_ ,  $uptime."$_")
        }
  EOF
    ) do
      its(:stdout) { should match /Days : 0/io }
      its(:stdout) { should match /Hours : 0/io }
    end
  end

  # origin: https://github.com/singlestone/Windows_Scripts_Examples/blob/master/WindowsServerSpec_Example/Script_Modules/Eventlog_Functions.psm1
  # TODO: https://rubygems.org/gems/win32-eventlog/versions/0.6.5, https://github.com/chef/win32-eventlog
  context 'Eventlog' do

    describe command(<<-EOF

      $serverName = '.'
      # computes the server uptime hours
      $lastBoot = Get-EventLog -ComputerName $serverName -newest 1  -LogName System -Source 'EventLog' -InstanceID 2147489653
      $upTime = new-timespan -Start (get-date $lastBoot.TimeGenerated) -End (get-date)
      # message posted when 'the Event Log service is restarted.'
      # write-output ('Uptime: {0} hours' -f ($upTime.TotalHours).tostring('#.#')  )
      # possible error: Cannot find an overload for "tostring" and the argument count: "1".
      write-output ('Uptime: {0} hours' -f [Math]::round($upTime.TotalHours, 1) )

      # computes the server downtime offline during last reboot
      $lastShutdown = Get-EventLog -ComputerName $serverName -newest 1  -LogName System -Source 'EventLog' -InstanceID 2147489654
      # the event message posted when 'the Event log service was stopped.'
      # This event is seen during shutdown of the computer. It should be one of the last events to be logged before the next event with ID 6009 is logged.
      # a.k.a Event ID 6006
      $Shutdown = get-date $lastShutdown.TimeGenerated
      $DownTime = new-timespan -Start (get-date $lastShutdown.TimeGenerated) -End (get-date $lastBoot.TimeGenerated)
      write-output ('Offline: {0} minutes' -f [Math]::round($DownTime.TotalMinutes,0) )

  EOF
    ) do
      its(:stdout) { should match /Uptime: 0\.\d hours/io }
      its(:stdout) { should match /Offline: \d+ minutes/io }
    end
  end
end
