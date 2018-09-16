describe package('vim-minimal') do
  it { should be_installed }
  its('version') { should eq node.value(['vim','version']) }
end

describe command('/usr/sbin/sestatus -v') do
  its('stdout') { should match('Current mode:\s.*?permissive') }
end

describe file('/etc/sudoers') do
  its('content') { should match('admin ALL=\(ALL\) NOPASSWD:ALL') }
  its('content') { should match('wheel ALL=\(ALL\) NOPASSWD:ALL') }
  its('content') { should match('Dev-Ops ALL=\(ALL\) NOPASSWD:ALL') }
end

describe file('/tmp/client.rb') do
  its('content') { should match 'Ohai::Config\[:disabled_plugins\] = \[:Passwd,:Rackspace,:DMI,:Erlang,:Groovy,:PHP,:Eucalyptus,:NetworkListeners,:Mono,:Go,:Lua,:Rust,:Joyent,:DigitalOcean,:solaris2,:openbsd\]' }
end

if os.redhat?
  describe service('iptables') do
    it { should be_enabled }
  end
end

ip_tables_expected_rules = [
  %r{-A INPUT -m state --state RELATED,ESTABLISHED -m comment --comment "established" -j ACCEPT},
  %r{-A INPUT -p tcp -m tcp -m multiport --dports 22 -m comment --comment "allow world to ssh" -j ACCEPT},
  %r{-A INPUT -s 127.0.0.1/32 -p tcp -m tcp -m multiport --dports 0:65535 -m comment --comment "localhost tcp" -j ACCEPT} ]

describe command('/sbin/iptables-save') do
  its('stdout') { should match(/COMMIT/) }
  ip_tables_expected_rules.each do |r|
    its('stdout') { should match(r) }
  end
end

describe file('/etc/ssh/sshd_config') do
  its('content') { should match('ChallengeResponseAuthentication no') }
end

if os.redhat?
  describe file('/etc/ssh/sshd_config') do
    # redhat specifics
    its('content') { should match('Subsystem\s*sftp\s*\/usr\/libexec\/openssh\/sftp-server') }
  end
  if os[:release].to_f >= 7
    describe file('/etc/ssh/sshd_config') do
      # release specifics
      its('content') { should match('UsePrivilegeSeparation\s*sandbox') }
    end
  end
end
