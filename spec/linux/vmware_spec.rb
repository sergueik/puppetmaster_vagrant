require 'spec_helper'
# require_relative '../type/cron'
context 'vmware plugin' do
  context 'Services' do
    describe service('vmtoolsd') do
      it { should be_installed } # may be problem 
      it { should be_running }
    end
    describe file('/usr/lib/systemd/system/vmtoolsd.service') do
      it { should be_file }
      it { should be_owned_by 'root' }
      its(:content) { should match(Regexp.new('Description=Service for virtual machines hosted on VMware'))}
    end
    describe file('/etc/systemd/system/multi-user.target.wants/vmtoolsd.service') do
      it { should be_symlink }
      it { should be_linked_to '/usr/lib/systemd/system/vmtoolsd.service' }
    end
  end
  context 'Processes' do
    describe process('vmtoolsd') do
      it { should be_running }
      its(:user) { should eq 'root' }
      its(:args) { should match(Regexp.new('-n vmusr'))}
    end
  end
    context 'Files' do
     [
        'vmw_vsock_vmci_transport',
        'vmwgfx',
        'vmw_vmci',
        'vmw_balloon'
      ].each do |file|
      describe file("/sys/module/#{file}") do
        it { should be_directory }
      end
    end
     [
        'vmware-checkvm',
        'vmware-guestproxycerttool',
        'vmware-rpctool',
        'vmware-xferlogs',
        'vmware-hgfsclient',
        'vmware-toolbox-cmd',
        'vmware-vmblock-fuse',
        'vmware-user-suid-wrapper',
      ].each do |file|
      describe file("/usr/bin/#{file}") do
        it { should be_file }
      end
    end
    [
      '/etc/vmware-tools/GuestProxyData/server/key.pem',
      '/etc/vmware-tools/GuestProxyData/server/cert.pem',
      '/etc/vmware-tools/guestproxy-ssl.conf',
      '/etc/vmware-tools/resume-vm-default',
      '/etc/vmware-tools/poweroff-vm-default',
      '/etc/vmware-tools/suspend-vm-default',
      '/etc/vmware-tools/poweron-vm-default',
      '/etc/vmware-tools/scripts/vmware/network',
      '/etc/vmware-tools/statechange.subr',
    ].each do |file|
      describe file(file) do
        it { should be_file }
      end
    end
  end
end
