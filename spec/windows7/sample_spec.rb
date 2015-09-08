require_relative '../windows_spec_helper'

context 'Commands' do
  describe command ('ipconfig ') do
    its(:stdout) { should match /^Windows IP Configuration/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command ('& "ipconfig" ') do
    its(:stdout) { should match /^Windows IP Configuration/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command ('(get-CIMInstance "Win32_ComputerSystem" -Property "DNSHostName").DNSHostName') do
    its(:stdout) { should match /\bwindows7\b/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
end
# TODO :VBA 
context 'Junctions ans Reparse Points' do

  describe command( <<-EOF
# Confirm that a given path is a Windows NT symlink
function Test-SymLink([string]$test_path) {
  $file_object = Get-Item $test_path -Force -ErrorAction Continue
  return [bool]($file_object.Attributes -band [IO.FileAttributes]::Archive ) `
               -and  `
         [bool]($file_object.Attributes -band [IO.FileAttributes]::ReparsePoint )
}

# Confirm that a given path is a Windows NT directory junction 
function Test-DirectoryJunction([string]$test_path) {
  $file_object = Get-Item $test_path -Force -ErrorAction Continue
  return [bool]($file_object.Attributes -band [IO.FileAttributes]::Directory ) `
               -and  `
         [bool]($file_object.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

# what is the API to read directory junction target ? 
function Get-DirectoryJunctionTarget([string]$test_path) {

  $command = ('cmd /c dir /L /-C "{0}"' -f 
              [System.IO.Directory]::GetParent($test_path ))
  $capturing_match_expression = ( '<JUNCTION>\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f 
                                  [System.IO.Path]::GetFileName($test_path ))
  $result = $null
  (invoke-expression -command $command ) | 
            where-object { $_ -match $capturing_match_expression } |
              select-object -first 1 | 
                forEach-object { 
                  $result =  $matches['TARGET'] 
                }
  return $result

}

# What is the API to read symlink target ? 
function Get-SymlinkTarget([string]$test_path) {

  $command = ('cmd /c dir /L /-C "{0}"' -f [System.IO.Directory]::GetParent($test_path ))
  $capturing_match_expression = ( '<SYMLINK>\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f 
                                  [System.IO.Path]::GetFileName($test_path ))
  $result = $null
  (invoke-expression -command $command ) | 
    where { $_ -match $capturing_match_expression } |
      select-object -first 1 | 
        forEach-object { 
          $result =  $matches['TARGET'] 
        }
  return $result

}


$is_junction = Test-DirectoryJunction -test_path 'c:\\temp\\test'
write-output ('is junction: {0}' -f $is_junction )

$junction_target = Get-DirectoryJunctionTarget  -test_path 'c:\\temp\\test'
write-output ('junction target: {0}' -f $junction_target )

$is_symlink = Test-Symlink -test_path 'c:\\temp\\specinfra'
write-output ('is symlink: {0}' -f $is_symlink )

$symlink_target = Get-SymlinkTarget  -test_path 'c:\\temp\\specinfra'
write-output ('symlink target: {0}' -f $symlink_target )

EOF
) do
    its(:exit_status) {should eq 0 }
    its(:stdout) { should match /is symlink: True/  }
    its(:stdout) { should match /symlink target: specinfra-2.43.5.gem/i   }
    its(:stdout) { should match /is junction: True/  }
    its(:stdout) { should match /junction target: c:\\windows\\softwareDistribution/i   }
  end

end


context 'Writing Files' do
  describe command 'Add-Content -Path "C:\\temp\\a.txt" -Value @(1,2,3)' do
    its(:exit_status) {should eq 0 }
  end
  describe command 'write-output "123" | out-file -filepath "c:\\temp\\a.txt" -append' do
    its(:exit_status) {should eq 0 }
  end
end

context 'Command Output' do
  # Pre-command does not work - invalid Powershell sytnax in generated command
  # let(:pre_command) { 'write-output "123" | out-file -filepath "c:\\temp\\a.txt" -append' }
  # let(:pre_command) { '(Add-Content -Path "C:\\temp\\a.txt" -Value @(4,5,6))'  }

  describe file( "c:\\temP\\a.txt") do

    it { should be_file  }
    it { should contain(/1|2|3/)  }
  end
end


context 'Inspecting registry key created by the installer' do
  describe command ( <<-EOF 
$version = '2.6.4'
$nunit_registry_key = "HKCU:\\Software\\nunit.org\\NUnit\\${version}"
if (-not (Get-ChildItem $nunit_registry_key -ErrorAction 'SilentlyContinue')){
  throw 'Nunit is not installed.'
}
$item = (Get-ItemProperty -Path $nunit_registry_key ).InstallDir
$nunit_install_dir = [System.IO.Path]::GetDirectoryName($item)

$assembly_list = @{
  'nunit.core.dll' = 'bin\\lib';
  'nunit.framework.dll' = 'bin\\framework';
}

pushd $nunit_install_dir
foreach ($assembly in $assembly_list.Keys)
{
  $assembly_path = $assembly_list[$assembly]
  pushd ${assembly_path}
  Write-Debug ('Loading {0} from {1}' -f $assembly,$assembly_path )
  if (-not (Test-Path -Path $assembly)) {
    throw ('Assembly "{0}" not found in "{1}"' -f $assembly, $assembly_path )
  }
  Add-Type -Path $assembly
  popd
}

[NUnit.Framework.Assert]::IsTrue($true)

EOF
) do
    its(:exit_status) {should eq 0 }
    its(:stderr) { should be_empty }
  end
end

context 'Loading assembly from the CAC' do

  describe command (<<-EOF 
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$o = New-Object System.Windows.Forms.Form
write-output ($o.getType().Namespace)
EOF
) do
    its(:stdout) { should match /System.Windows.Forms/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end

  # http://www.madwithpowershell.com/2013/10/add-type-vs-reflectionassembly-in.html
  describe command (<<-EOF 
$long_name = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
[reflection.assembly]::Load($long_name)
EOF
) do
    its(:exit_status) {should eq 0 }
  end

  describe command (<<-EOF
([System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')).GetExportedTypes() |
foreach-object { 
  if ($_.Name -eq 'Form') {
    write-output $_.NameSpace
  }
}
 EOF
) do
    its(:stdout) { should match /System.Windows.Forms/ }
  end

  describe command (<<-EOF
$verify_assemblies = @(
  @{
   'Name' = 'System.Windows.Forms';
   'FullName' = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089';
  }
)
$verify_assemblies | foreach-object {
  $assembly_name = $_['Name']
  $assembly_full_name = $_['FullName']

  [void][System.Reflection.Assembly]::LoadWithPartialName($assembly_name)
  $loaded_assemblies = [System.Threading.Thread]::GetDomain().GetAssemblies()
  $loaded_assemblies | where-object {$_.GetName().Name -match $assembly_name } | 
    foreach-object {
      if ( $_.GetName().FullName -ne $assembly_full_name ){
        Write-Error ('Wrong assembly for "{0}": "{1x}"' -f $assembly_name, $_.GetName().FullName)
      }
  }
}
 EOF
) do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should be_empty }
  end

  describe command (<<-EOF 
add-Type @"
using System;
using System.Windows.Forms;

using System.Reflection;
using System.Threading;
using System.IO;
using System.Globalization;
using System.Reflection.Emit;
using System.Configuration.Assemblies;
using System.Text;

public class ClassTest : Form
{
 public static void Test()
   {
      Assembly[] myAssemblies = Thread.GetDomain().GetAssemblies();

      Assembly myAssembly = null;
      for(int i = 0; i < myAssemblies.Length; i++)
         if(String.Compare(myAssemblies[i].GetName().Name, "System.Drawing") == 0)
            myAssembly = myAssemblies[i];

      if(myAssembly != null)
      { 
         
         string name = myAssembly.GetName().Name;
         string assemblyName = myAssembly.GetName().FullName;
         byte[] publicKeyTokenBytes = myAssembly.GetName().GetPublicKeyToken();
         Console.WriteLine(String.Format("{0}\\n{1}\\n{2}\\n", name, assemblyName, Encoding.UTF8.GetString(publicKeyTokenBytes)));
      }

}

}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.ComponentModel.dll', 'System.IO.dll', 'mscorlib.dll'

[ClassTest]::Test()
 EOF
) do
    its(:stdout) { should match /System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
end 

context 'Inspecting Environment' do

  describe command (<<-EOF 
$environment_path = 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' 
write-output (Get-ItemProperty -Path $environment_path ).Path

EOF
) do
    its(:stdout) { should match /c:\\opscode\\chef\\bin/io }
  end
  describe command (<<-EOF 
write-output ([Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine))

EOF
) do
    its(:stdout) { should match /c:\\opscode\\chef\\bin/io }
  end




  # note non-standard syntax
  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    it { should exist }
    it { should have_property('Path', :type_string) }
    it { should have_property_value( 'OS', :type_string_converted, 'Windows_NT' ) }
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

context 'Default Site' do
  describe windows_feature('IIS-Webserver') do
    it{ should be_installed.by('dism') }
  end
  describe iis_app_pool('DefaultAppPool') do
    it{ should exist }
  end
  describe file('c:/inetpub/wwwroot') do
    it { should be_directory }
  end
end
context 'mysite' do
  describe iis_app_pool('my_application_pool') do
    it{ should exist }
    it{ should have_dotnet_version('4.0') }
    it{ should have_managed_pipeline_mode('integrated') }
  end
  describe iis_website('www.mysite.com') do
    xit{ should be_installed }
    it{ should exist }
    it{ should be_enabled }
    it{ should be_running }
    it{ should have_physical_path('C:\\inetpub\\wwwroot\\mysite') } 
    it{ should be_in_app_pool('my_application_pool') }
    it{ should have_site_application('application1') }
    it{ should have_site_bindings('8080','http','*') }
  end
  describe file('c:/inetpub/wwwroot/mysite') do
    it { should be_directory }
  end
  describe file( 'c:/windows/system32/inetsrv/config/applicationHost.config') do
    # let(:pre_command) { 'start-sleep -seconds 120 '  }
    it { should be_file  }
    it { should contain('www.mysite.com')  }
  end
  describe port(8080) do
    it { should be_listening }
  end
end
context 'World Wide Web Publishing Service' do
  describe service('W3SVC') do
    # comment slow command
    it { should be_running }
  end
end
context 'Windows Process Activation Service' do
  describe service('WAS') do
    # comment slow command
    it { should be_running }
  end
end





# require 'spec_helper'
# does not work with windows_spec ?

# describe 'test' do
#  include_examples 'iis::init'
# end



