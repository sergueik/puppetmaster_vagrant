require_relative '../windows_spec_helper'

context 'Environment' do

  describe command (<<-EOF
  $environment_path = 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment'
  write-output (Get-ItemProperty -Path $environment_path ).Path

  EOF
  ) do
      its(:stdout) { should match /c:\\opscode\\chef\\bin/io }
    end
  describe command (<<-EOF
  write-output (([Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -replace '\\\\', '/'))
  EOF
  ) do
    its(:stdout) { should match /c:\/opscode\/chef\/bin/i }
  end
  # note differences in registry hive / path formatting syntax between Ruby and Powershell

  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    it do
      should exist
      should have_property('Path', :type_string)
      should have_property_value( 'OS', :type_string_converted, 'Windows_NT' )
    end
  end
  describe windows_registry_key('HKLM\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine') do
    # does not work with :type_string_converted
    it { should have_property_value('PowerShellVersion' , :type_string ,'4.0' ) }
  end

  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do

    let(:value_check) do
      { :name  => 'OS',
        :type  => :type_string_converted,
        :value => 'x86'
     }
    end
    # it { should have_property_value( value_check ) }
    # requires custom specinfra.gem to support property_value_containing
    # xit { should have_property_valuecontaining( 'Path', :type_string_converted, 'c:\\\\windows' ) }
  end

end
