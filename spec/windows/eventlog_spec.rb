context 'Event Log' do # http://ss64.com/ps/get-winevent.html
  # Log Name : Application
  # Source: RestartManager
  # EventID: 10001
  # Text: Ending session 0 started 2016-01-28T14:44:21.217074400Z.
  # 
  # EventID: 10000
  # Text: Starting session 0 - 2016-01-28T14:41:49.061645600Z.
  event_log_id = 1074
  describe command(<<-EOF
$Id = '#{event_log_id}'
get-winevent -FilterHashTable @{LogName='System'; ID=$Id; } -MaxEvents 10  |
sort-object TimeCreated -descending | 
select-object -first 1 | 
select-object -property Message | 
format-list
EOF
  ) do
    its(:stdout) { should match /Shutdown Type:/io } 
  end
end
