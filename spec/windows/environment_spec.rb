require_relative '../windows_spec_helper'

context 'Inspecting Environment' do

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
  # note non-standard syntax
  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    it { should exist }
    it { should have_property('Path', :type_string) }
    it { should have_property_value( 'OS', :type_string_converted, 'Windows_NT' ) }
  end
  describe windows_registry_key('HKLM\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine') do
    # does not work with  :type_string_converted
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

    # xit { should have_property_valuecontaining( 'Path', :type_string_converted, 'c:\\\\windows' ) }
    # error: expected Windows registry key to respond to `has_property_valuecontaining?`
  end

end
