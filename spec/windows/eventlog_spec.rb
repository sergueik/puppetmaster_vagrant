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
        # seems to fail
        its(:stdout) { should match(/#{message[0]}/io) or match(/#{message[1]}/) }
        its(:stdout) { should match(/(?:#{message[0]}|#{message[1]})/) }
      end
    end
  end
end
