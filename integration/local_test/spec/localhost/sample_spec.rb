require 'spec_helper'

describe file('/tmp/purge_old_dirs.sh') do
  it { should exist }
  its(:content) { should include 'script for jenkins job'}
  # NOTE: there may be inconsistency between the actual datadir and contents of '/etc/my.cnf'
  context 'Mysql Datadir' do
    custom_datadir = '/opt/mysql/var/lib/mysql/'
    describe command(<<-EOF
      mysql -sBEe 'select @@datadir;'
    EOF
    ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /@@datadir: #{custom_datadir}/i }
    end
    # NOTE trailing slash processing
    default_datadir = '/var/lib/mysql'
    default_datadir = custom_datadir.gsub(/\/$/,'')
    custom_datadir = '/opt/mysql/var/lib/mysql'
    describe command(<<-EOF
      echo $(mysql -sBEe 'select @@datadir;' | awk '/@@datadir/ {print $2}' | sed 's|/$||')
      readlink $(mysql -sBEe 'select @@datadir;' | awk '/@@datadir/ {print $2}' | sed 's|/$||')
    EOF
    ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match default_datadir }
      its(:stdout) { should match custom_datadir }
    end
  end

end
