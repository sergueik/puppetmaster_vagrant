require 'spec_helper'

context 'Logrotate config' do
  describe command(<<-EOF
    /usr/sbin/logrotate --verbose --debug /etc/logrotate.conf
  EOF
  ) do
    its(:exit_status) { should eq 0 }
  end
end