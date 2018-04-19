require 'spec_helper'

context 'MySQL' do
  context 'General Log' do
    general_log = '/var/lib/mysql/' + %x|hostname -s|.chomp! + '.log'
    describe command(<<-EOF
      lsof /var/lib/mysql/$(hostname -s).log | grep $(pgrep -a mysqld |  grep 'mysqld ' |  cut -d ' ' -f 1  | head -1) 2>/dev/null
    EOF
    ) do
      its(:stdout) { should contain general_log }
      its(:exit_status) {should eq 0 }
      its(:stdout) { should_not contain 'No such file or directory' }
      its(:stdout) { should_not match /usage:/i }
    end
    describe command(<<-EOF
     GENERAL_LOG='#{general_log}'		
     PID=$(pgrep -a mysqld |  grep 'mysqld ' |  cut -d ' ' -f 1  | head -1)
     lsof $GENERAL_LOG | grep $PID
    EOF
    ) do
      its(:stdout) { should contain general_log }
      its(:exit_status) {should eq 0 }
      its(:stdout) { should_not contain 'No such file or directory' }
      its(:stdout) { should_not match /usage:/i }
    end
  end
end

