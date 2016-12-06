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
        write-output ('{0}: {1}' -f $property_name, (get-item "Registry::${service_registry_path}").GetValue($property_name))
        $status = [Bool](( Compare-Object (Get-Item "Registry::${service_registry_path}").GetValue($property_name) $property_value ) -eq $null )
        write-output ('status: {0}' -f $status)
      EOF
      ) do
        its (:stdout) { should match /#{property_name}: #{value}/ }
        its (:stdout) { should match /status: true/i }
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
    }.each do |service_name, servicetype|      describe command(<<-EOF
        get-service -name '#{service_name}' | select-object -property name,servicetype | format-list
      EOF
      ) do
        its(:stdout) { should contain servicetype }
       end
    end
  end
end
