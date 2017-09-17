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
      get-winevent -FilterHashTable @{
        LogName=$log_name; 
        ID=$event_log_id; 
      } -MaxEvents 10 |
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
      get-winevent -FilterHashTable @{ 
        LogName=$log_name; 
        ID=$event_log_id; } -MaxEvents 10 |
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
          [int]$numLastDays = 50
        )

        $queryDateDiff =
        if ($numLastDays) {
          $dateDiffValue = [math]::Round((Get-Date).Subtract((Get-Date).AddDays(- $numLastDays)).TotalMilliseconds)
          " and (TimeCreated[timediff(@SystemTime) <= $dateDiffValue])"
        }

        $eventId = '#{event_id}'
        $eventLogName = '#{event_log_name}'

        $o = Get-WinEvent -ErrorAction silentlycontinue -LogName $eventLogName -FilterXPath (@"
        *[
        (
          System[(EventID=${eventId}) $queryDateDiff] and
          EventData[
            (Data[@Name='LogonType']=2) or
            (Data[@Name='LogonType']=10)
          ]
        )
        ]
"@ -join '' -replace "`r?`n",'');

        if ($o -ne $null) {
          $o |
          foreach-object { write-output ([xml]$_.ToXml()) } |
          foreach-object { $_.Event } |
          select-object @(
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

  # https://blogs.technet.microsoft.com/heyscriptingguy/2011/01/25/use-powershell-to-parse-saved-event-logs-for-errors/
  describe 'Window event' do
    describe command(<<-EOF
      param(
        [int]$LogName = 'Application'
      )
      get-childItem -Include "${LogName}.*" -Path 'c:\Windows\system32\winevt\Logs' -Recurse |
      foreach-object {
        write-output "Parsing $($_.fullname)`r`n"
        try {
          Get-WinEvent -FilterHashtable @{
            LogName = $_.BaseName;
            ProviderName = 'Application Error';
            Path = $_.fullname;
            Level = 2;
            StartTime = "1/1/2017";
            EndTime = "8/5/2017";
          } -ErrorAction Stop |
          Where-Object { -not ($_.Message -match 'Faulting application name: (?:firefox.exe|plugin-container.exe|SharpDevelop.exe|stardict.exe|devenv.exe)') } |
          select-object -First 10 | select-object -Property TimeCreated,Message,LevelDisplayName,Id | format-list}
        catch [System.Exception]{ write-output 'No errors in current log' }
      }
      EOF
      ) do
        its(:stdout) { should be_empty/) }
      end
  end
end