require_relative '../windows_spec_helper'

context  'ServiceType' do
  context 'Registry Keys' do
    {
      'usbohci'=> '1',
      'vaultsvc' => '32',
      'TrustedInstaller' => '272',
    }.each do |name, value|
      describe windows_registry_key("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\#{name}") do
        it{ should exist}
        it{ should have_property_value('Type', :type_dword, type ) }
      end
      # run specinfra command directly here
      describe command(<<-EOF
        $registry_path = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\#{name}'
        $property_name = 'Type'
        $property_value = #{value}
        (get-item "Registry::${registry_path}").GetValue($property_name) 
        $status = (Compare-Object (Get-Item "Registry::${registry_path}").GetValue($property_name) $property_value ) -eq $null )
        write-output ('status: {0}' -f $status)
      EOF
      ) do
        its (:stdout) { should contain value }
        its (:stdout) { should contain 'status: true' }
      end
    end
  end
      
  context 'Cmdlet' do    
    {
      'vaultsvc' => 'Win32ShareProcess',
      'usbohci' => 'KernelDriver',
      'TrustedInstaller' => 'Win32OwnProcess',
      'UI0Detect' => 'Win32OwnProcess, InteractiveProcess',
    }.each do |name, servicetype|      describe command(<<-EOF
        get-service -name '#{name}' | select-object -property name,servicetype | format-list
      EOF
      ) do
        its(:stdout) { should contain servicetype }
       end
    end
  end
end
