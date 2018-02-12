if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
if File.exists?( 'spec/serverspec/versions.rb')
  require_relative 'versions.rb'
  end
context 'Hypervisor' do
  describe command(<<-EOF
    $manufacturers =  @(
      'Oracle Corporation'
    )
    $items = get-wmiobject -class 'Win32_PnPEntity' -namespace 'root\\CIMV2' -computername '.' |
    where-object { $_.Status -eq 'OK' } |
    where-object {
      $manufacturer = $_.Manufacturer
      # write-output $manufacturer
      $result = [Array]::Find($manufacturers, [Predicate[String]]{
        # write-output ("got {0}" -f $manufacturer )
        $args[0] -eq $manufacturer
      })
      # write-output ('result = {0}'  -f $result )
      $result -ne $null
    }
    # write-output $colItems.Length
    foreach ($item in $items) {
      write-output ('Caption: '  + $item.Caption )
      write-output ('Creation Class Name: ' + $item.CreationClassName)
      write-output ('Description: ' + $item.Description)
      write-output ('Device ID: '  + $item.DeviceID)
      write-output ('Manufacturer: '  + $item.Manufacturer)
      write-output ('Name: ' +  $item.Name)
      write-output ('Service: '  + $item.Service)
      write-output ('Status: '  + $item.Status )
      write-output ''
    }
    EOF
    ) do
      its(:stdout) { should match Regexp.new('Name: VirtualBox Device' ) }
      its(:stdout) { should match Regexp.new('Service: VBoxGuest' ) }
    end
  end
