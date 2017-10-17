require 'spec_helper'
require 'pp'

context 'vmware plugin' do
  context 'Packages' do
    describe package('VMware Tools') do
      it { should be_installed }
    end
  end
  context 'Services' do
   [
    'VMTools',
    'VMware Physical Disk Helper Service',
    'VGAuthService'
    ].each do |service_name|
      describe service(service_name) do
        it { should be_installed } # may be problem
        it { should be_running }
      end
    end
  end
  context 'Processes' do
    describe process('vmtoolsd.exe') do
      it { should be_running }
      # CommandLine
      # "C:\Program Files\VMware\VMware Tools\vmtoolsd.exe"
      # "C:\Program Files\VMware\VMware Tools\vmtoolsd.exe" -n vmusr
      # Need to fix specinfra to make this test pass
      # Get-WmiObject Win32_Process -Filter "name = 'vmtoolsd.exe'" | select -First 1 commandline -ExpandProperty commandline
      its(:commandline) { should match(Regexp.new('-n vmusr'))}
    end
  end
  context 'Files' do
    [
      'Drivers',
      'messages',
      'plugins',
      'VMware VGAuth',
      'win32'
     ].each do |file|
       describe file("c:\\Program Files\\VMware\\VMware Tools\\#{file}") do
         it { should be_directory }
       end
    end
    [
      'guestproxycerttool.exe',
      'openssl.exe',
      'rpctool.exe',
      'rvmSetup.exe',
      'TPAutoConnect.exe',
      'TPAutoConnSvc.exe',
      'TPVCGateway.exe',
      'vmacthlp.exe',
      'vmtoolsd.exe',
      'VMwareHgfsClient.exe',
      'VMwareHostOpen.exe',
      'VMwareNamespaceCmd.exe',
      'VMwareResolutionSet.exe',
      'VMwareToolboxCmd.exe',
      'VMwareXferlogs.exe',
      'zip.exe'
    ].each do |file|
      describe file("c:\\Program Files\\VMware\\VMware Tools\\#{file}") do
        it { should be_file }
      end
    end
  end

  context 'Registry Keys' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\VMware, Inc.\VMware Drivers') do
    {
      'es1371.status' => '1|1.5.10.0.3506.1|oem9.inf',
      'VmciHostDevInst' => 'ROOT\\VMWVMCIHOSTDEV\\0000',
      'vmci.status' => '1|1.9.8.6.0.1|oem4.inf',
      'vsock.status' => '1|4998961.9.8.8.0.1|C:\\Windows\\system32\\DRVSTORE\\vsock_97B97D0CD9C17FE010D062C2251E35395FD89864\\vsock.inf',
      'vsockSys.status' => '1|4998961.9.8.8.0.1|C:\\Windows\\system32\\DRVSTORE\\vsock_97B97D0CD9C17FE010D062C2251E35395FD89864\\vsock.inf',
      'vsockDll.status' => '1|4998961.9.8.8.0.1|C:\\Windows\\system32\\DRVSTORE\\vsock_97B97D0CD9C17FE010D062C2251E35395FD89864\\vsock.inf',
      'vmxnet3.status' => '1|1.1.7.3.0.1|oem5.inf',
      'pvscsi.status' => '1|1.1.3.8.0.1|oem6.inf',
      'vmusbmouse.status' => '1|1.12.5.7.0.1|oem11.inf',
      'vmmouse.status' => '1|1.12.5.7.0.1|oem12.inf',
      'vmmemctl.status' => '1|4998961.7.4.1.1.1|C:\\Windows\\system32\\DRVSTORE\\vmmemctl_2782EFE307416199E2B347224E0710E0C59C5639\\vmmemctl.inf',
      'vmhgfs.status' => '1|4998961.11.0.14.2.1|C:\\Windows\\system32\\DRVSTORE\\vmhgfs_BE110F6B7FA9516EDD3CC96500289EEA849283A7\\vmhgfs.inf',
      'vmrawdsk.status' => '1|4998961.1.1.0.1.1|C:\\Windows\\system32\\DRVSTORE\\vmrawdsk_53F3E5E23861959CADEF8EAC62691B476F7E2E31\\vmrawdsk.inf',
      'svga_wddm.status' => '1|1.8.15.1.50.1|oem10.inf',
    }.each do |property_name, property_value|
        it { should have_property_value(property_name, :type_string, property_value) }
      end
    end
  end
end