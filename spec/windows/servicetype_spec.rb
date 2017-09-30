require_relative '../windows_spec_helper'

context  'ServiceType' do
  context 'Registry Keys' do
    property_name = 'Type'
    {
      'usbohci'=> '1',
      'Dfsc' => '2',
      'RpcLocator' => '16',
      'CryptSvc' => '32',
      'Spooler' => '272',
    }.each do |service_name, value|
      describe windows_registry_key("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\#{service_name}") do
        it{ should exist}
        # NOTE: the following fails due to a possible bug in Specinfra::Command::Windows::Base::RegistryKey.convert_key_property_value
        # it{ should have_property_value('Type', :type_dword, value ) }
        it{ should have_property_value(property_name, :type_dword_converted, value ) }
      end
      # run specinfra command directly here
      describe command(<<-EOF
        $service_registry_path = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\#{service_name}'
        $property_name = '#{property_name}'
        $property_value = #{value}
        write-output ('{0}: {1}' -f $property_name, (get-item "Registry::${service_registry_path}").getvalue($property_name))
        $status = [Bool](( Compare-Object (get-item "Registry::${service_registry_path}").getvalue($property_name) $property_value ) -eq $null )
        write-output ('status: {0}' -f $status)
      EOF
      ) do
        its (:stdout) { should match /#{property_name}: #{value}/ }
        its (:stdout) { should match /status: true/i }
      end
    end
  end

  # origin: https://github.com/SHIFT-ware/shift_ware/blob/master/Serverspec/spec/2-0001_Base/Advanced/2-0001-096_Service_spec.rb
  context 'Powershell snippet for Service Registry Key probe' do
    property_name = 'Type'
    {
      'WinRM'=> {'DelayedAutoStart' => '1'},
    }.each do |service_name, data|
      data.each do |data_key,data_value|
        describe command ("write-host -nonewline ((get-itemproperty HKLM:\\SYSTEM\\CurrentControlSet\\services\\$((get-service -displayName '#{service_name}').Name)).#{data_key})") do
          its (:stdout) { should match data_value }
        end
      end
    end
    [
      'Appinfo',
      'DeviceInstall',
      'RemoteRegistry',
      'W32Time',
    ].each do |service_name|
      describe command("write-host -nonewline (test-path HKLM:\\SYSTEM\\CurrentControlSet\\services\\$((get-service -name '#{service_name}').Name)\\TriggerInfo)") do
        its (:stdout) { should eq 'True' }
      end
    end
  end
  context 'Cmdlet' do
    {
      'usbohci' => 'KernelDriver',
      'Dfsc' => 'FileSystemDriver',
      'RpcLocator' => 'Win32OwnProcess',
      'CryptSvc' => 'Win32ShareProcess',
      'Spooler' => 'Win32OwnProcess, InteractiveProcess',
    }.each do |service_name, servicetype|
        describe command(<<-EOF
        get-service -name '#{service_name}' | select-object -property name,servicetype | format-list
      EOF
      ) do
        its(:stdout) { should contain servicetype }
       end
    end
  end
end