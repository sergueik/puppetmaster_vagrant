context 'Event Log' do # http://ss64.com/ps/get-winevent.html
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
