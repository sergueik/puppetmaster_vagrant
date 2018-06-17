require_relative '../windows_spec_helper'

# expectations that the package install location is added to system PATH in Windows
context 'Environment' do

  install_location = 'C:/Program Files/Puppet Labs/Puppet/bin'
  registry_key = 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment'

  [
    registry_key,
    registry_key.gsub(/\\\\/,'/'),
  ].each do |regkey|
    describe command (<<-EOF
      write-output ((Get-ItemProperty -Path '#{regkey}' ).Path -replace '\\\\', '/' )
    EOF
    ) do
        its(:stdout) { should match Regexp.new(install_location, Regexp::IGNORECASE) }
      end
  end
  describe command ('([Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)) -replace "\\\\", "/" ') do
    its(:stdout) { should match Regexp.new(install_location, Regexp::IGNORECASE) }
  end

  # NOTE: backslashes translated
  install_location_converted = install_location.gsub('\\','/')
  describe command ('([Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)) -replace "\\\\", "/"') do
     its(:stdout) { should match Regexp.new(install_location_converted, Regexp::IGNORECASE) }
  end

  # NOTE: differences in registry hive / path formatting syntax between Ruby and Powershell
  [
    registry_key,
    registry_key.gsub('HKLM','HKEY_LOCAL_MACHINE'),
  ].each do |wrong_formatted_key|
    describe windows_registry_key(wrong_formatted_key) do
      it { should_not exist }
    end
  end

  [
    registry_key,
    registry_key.gsub(/\\\\/,'/'),
  ].each do |regkey|
    describe windows_registry_key(regkey.gsub('HKLM:','HKEY_LOCAL_MACHINE')) do
      it do
        should exist
        should have_property('Path', :type_expandstring ) # ExpandString
        should have_property_value( 'OS', :type_string_converted, 'Windows_NT' )
      end
    end
    describe windows_registry_key(regkey.gsub('HKLM:','HKLM')) do
      it do
        should exist
        should have_property('Path', :type_expandstring )
        should have_property_value( 'OS', :type_string_converted, 'Windows_NT' )
      end
    end
  end

  # NOTE: this does not work with '/' path separators
  describe windows_registry_key('HKLM\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine') do
    # NOTE: this does not work with :type_string_converted
    it { should have_property_value('PowerShellVersion', :type_string ,'4.0' ) }
  end

  # NOTE: this test requires custom Specinfra with property_value_containing method
  describe windows_registry_key(registry_key) do

    let(:value_check) do
      { :name  => 'OS',
        :type  => :type_string_converted,
        :value => 'x86'
     }
    end
    # it { should have_property_value( value_check ) }
    # xit { should have_property_valuecontaining( 'Path', :type_string_converted, 'c:\\\\windows' ) }
  end

end
