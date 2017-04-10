require_relative '../windows_spec_helper'
# http://ss64.com/ps/get-winevent.html

context 'Event Log' do
  context 'Simple' do
    [
      {
        :event_log_id => 1074,
        :log_name => 'System',
        :source => 'RestartManager',
        :message => 'Shutdown Type:',
      }
    ].each do |row|
    event_log_id = row[:event_log_id]
    log_name = row[:log_name]
    source = row[:source]
    message = row[:message]
    describe command(<<-EOF
      $event_log_id = '#{event_log_id}'
      $log_name = '#{log_name}'
      get-winevent -FilterHashTable @{LogName=$log_name; ID=$event_log_id; } -MaxEvents 10  |
      sort-object TimeCreated -descending |
      select-object -first 1 |
      select-object -ExpandProperty 'Message'
      EOF
    ) do
        its(:stdout) { should match /#{message}/io }
      end
    end
  end
  context 'Multiple' do
    [
      {
        :event_log_id => 1074,
        :log_name => 'System',
        :source => 'RestartManager',
        :message => ['Shutdown Type:', ]
      },
      {
        :event_log_id => 10001,
        :log_name => 'Application',
        :source => 'RestartManager',
        :message => ['Ending session', 'Shutdown Type: power off']
      },
    ].each do |row|
    event_log_id = row[:event_log_id]
    log_name = row[:log_name]
    source = row[:source]
    message = row[:message]
    describe command(<<-EOF
      $event_log_id = '#{event_log_id}'
      $log_name = '#{log_name}'
      get-winevent -FilterHashTable @{LogName=$log_name; ID=$event_log_id; } -MaxEvents 10  |
      sort-object TimeCreated -descending |
      select-object -first 1 |
      select-object -ExpandProperty 'Message'
    EOF
    ) do
        # NOTE: doing 'or' this way seems to fail
        its(:stdout) { should match(/#{message[0]}/io) or match(/#{message[1]}/) }
        its(:stdout) { should match(/(?:#{message[0]}|#{message[1]})/) }
      end
    end
  end
  # http://www.cyberforum.ru/powershell/thread1948839.html
  context 'Advanced' do
    [
      {
        :event_id => 4624,
        :event_log_name => 'Security',
        :message => '127.0.0.1',
      }
    ].each do |row|
      event_id = row[:event_id]
      event_log_name = row[:event_log_name]
      source = row[:source]
      message = row[:message]
      describe command(<<-EOF
        param(
          [int]$LastDays = 50
        )

        $QueryDiff =
        if ($LastDays) {
          $Diff = [math]::Round((Get-Date).Subtract((Get-Date).AddDays(- $LastDays)).TotalMilliseconds)
          " and (TimeCreated[timediff(@SystemTime) <= $Diff])"
        }

        $eventId = '#{event_id}'
        $eventLogName = '#{event_log_name}'

        $o = Get-WinEvent -ErrorAction silentlycontinue -LogName $eventLogName -FilterXPath (@"
        *[
        (
          System[(EventID=${eventId}) $QueryDiff] and
          EventData[
            (Data[@Name='LogonType']=2) or
            (Data[@Name='LogonType']=10)
          ]
        )
        ]
"@ -join '' -replace "`r?`n",'');

        if ($o -ne $null) {
          $o |
          ForEach-Object { Write-Output ([xml]$_.ToXml()) } |
          ForEach-Object { $_.Event } |
          Select-Object @(
            @{ n = 'EventID'; e = { $_.System.EventID } },
            @{ n = 'TimeCreated'; e = { $_.System.TimeCreated.SystemTime | Get-Date } },
            @{ n = 'TargetUserSid'; e = { $_.EventData.SelectSingleNode('*[@Name="TargetUserSid"]').innertext } },
            @{ n = 'TargetUserName'; e = { $_.EventData.SelectSingleNode('*[@Name="TargetUserName"]').innertext } },
            @{ n = 'TargetDomainName'; e = { $_.EventData.SelectSingleNode('*[@Name="TargetDomainName"]').innertext } },
            @{ n = 'TargetLogonId'; e = { $_.EventData.SelectSingleNode('*[@Name="TargetLogonId"]').innertext } },
            @{ n = 'LogonType'; e = { $_.EventData.SelectSingleNode('*[@Name="LogonType"]').innertext } },
            @{ n = 'IpAddress'; e = { $_.EventData.SelectSingleNode('*[@Name="IpAddress"]').innertext } },
            @{ n = 'LogonGuid'; e = { $_.EventData.SelectSingleNode('*[@Name="LogonGuid"]').innertext } }
          )
        }
      EOF
      ) do
          its(:stdout) { should match(/(?:#{message})/) }
      end
    end
  end
end