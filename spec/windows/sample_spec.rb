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
  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    it { should respond_to(:exists?) }
    it { should exist }
    it { should respond_to(:has_property?).with(2).arguments }
    it { should respond_to(:has_property?).with(1).arguments }
    it { should have_property('Path', :type_string) }
    it { should respond_to(:has_value?).with(1).arguments }
    it { should have_property_value( 'OS', :type_string_converted, 'Windows_NT' ) }
     # for the next tests to pass
     # need to install modified specinfra.gem and serverspec.gem 
     # on the host
     it { should respond_to(:has_propertyvaluecontaining?).with(2).arguments }
     it { should have_propertyvaluecontaining('Path', 'c:\\\\windows') }
  end

context 'WinNT Groups' do
  
    describe command (<<-EOF
get-CIMInstance -Computername '.' -Query 'select * from win32_group where name like "ora%"' |
    select-object -property Name |
    convertto-json
EOF
) do
    # groups oracleuser does not belong 
    its(:stdout) { should match /"Name":  "ORA_ASMDBA"/io }
    its(:stdout) { should match /"Name":  "ORA_OPER"/io }
    its(:stdout) { should match /"Name":  "ora_dba"/io } 
    its(:stdout) { should match /"Name":  "ORA_CLIENT_LISTENERS"/io }
    its(:stdout) { should match /"Name":  "ORA_GRID_LISTENERS"/io }
    its(:stdout) { should match /"Name":  "ORA_INSTALL"/io }
    its(:stdout) { should match /"Name":  "ORA_OPER"/io }
    # installation specific Windows groups oracleuser would belong  
    its(:stdout) { should match /"Name":  "ORA_OraDB12Home1_DBA"/io }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end

end  
context 'Services' do
  describe command (<<-EOF

function FindService
{
  param([string]$name,
    [switch]$run_as_user_account
  )
  $local:result = @()
  $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '${name}' or DisplayName LIKE '${name}'" | Select Name,StartName,DisplayName,StartMode,State

  if ([bool]$PSBoundParameters['run_as_user_account'].IsPresent) {
    $local:result =  $local:result | Where-Object { -not (($_.StartName -match 'NT AUTHORITY') -or ( $_.StartName -match 'NT SERVICE') -or  ($_.StartName -match 'NetworkService' ) -or ($_.StartName -match 'LocalSystem' ))}
  }
    return $local:result


}

findService -Name '%' -run_as_user_account | ConvertTo-Json


EOF
) do
    its(:stdout) { should be_empty }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command (<<-EOF
function FindService
{
  param([string]$name,
    [switch]$run_as_user_account
  )
  $local:result = @()
  $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '${name}' or DisplayName LIKE '${name}'" | Select Name,StartName,DisplayName,StartMode,State

  if ([bool]$PSBoundParameters['run_as_user_account'].IsPresent) {
    $local:result =  $local:result | Where-Object { -not (($_.StartName -match 'NT AUTHORITY') -or ( $_.StartName -match 'NT SERVICE') -or  ($_.StartName -match 'NetworkService' ) -or ($_.StartName -match 'LocalSystem' ))}
  }
    return $local:result
}

findService -Name 'puppet' | ConvertTo-Json


EOF
) do
    its(:stdout) { should match /"DisplayName":  "Puppet Agent"/ }
    its(:stdout) { should match /"StartName":  "LocalSystem"/ }
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
  $capturing_match_expression = ( '(?:<JUNCTION>|<SYMLINKD>)\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f 
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


context 'Junctions ans Reparse Points with pinvoke' do
  # requires custom specinfra
  context 'Junctions ans Reparse Points' do
    describe file('c:/temp/xxx') do
     it { should be_symlink }
    end
  end
  describe command( <<-EOF

# use pinvoke to read directory junction /  symlink target 
#  http://chrisbensen.blogspot.com/2010/06/getfinalpathnamebyhandle.html
Add-Type -TypeDefinition @"
// "

using System;
using System.Collections.Generic;
using System.ComponentModel; // for Win32Exception
using System.Data;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class Utility
{

    private const int FILE_SHARE_READ = 1;
    private const int FILE_SHARE_WRITE = 2;

    private const int CREATION_DISPOSITION_OPEN_EXISTING = 3;

    private const int FILE_FLAG_BACKUP_SEMANTICS = 0x02000000;

    // http://msdn.microsoft.com/en-us/library/aa364962%28VS.85%29.aspx
    // http://pinvoke.net/default.aspx/kernel32/GetFileInformationByHandleEx.html

    // http://www.pinvoke.net/default.aspx/shell32/GetFinalPathNameByHandle.html
    [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int GetFinalPathNameByHandle(IntPtr handle, [In, Out] StringBuilder path, int bufLen, int flags);

    // https://msdn.microsoft.com/en-us/library/aa364953%28VS.85%29.aspx


    // http://msdn.microsoft.com/en-us/library/aa363858(VS.85).aspx
    // http://www.pinvoke.net/default.aspx/kernel32.createfile
    [DllImport("kernel32.dll", EntryPoint = "CreateFileW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern SafeFileHandle CreateFile(string lpFileName, int dwDesiredAccess, int dwShareMode,
    IntPtr SecurityAttributes, int dwCreationDisposition, int dwFlagsAndAttributes, IntPtr hTemplateFile);

    public static string GetSymbolicLinkTarget(DirectoryInfo symlink)
    {
        SafeFileHandle directoryHandle = CreateFile(symlink.FullName, 0, 2, System.IntPtr.Zero, CREATION_DISPOSITION_OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, System.IntPtr.Zero);
        if (directoryHandle.IsInvalid)
            throw new Win32Exception(Marshal.GetLastWin32Error());

        StringBuilder path = new StringBuilder(512);
        int size = GetFinalPathNameByHandle(directoryHandle.DangerousGetHandle(), path, path.Capacity, 0);
        if (size < 0)
            throw new Win32Exception(Marshal.GetLastWin32Error());
        // http://msdn.microsoft.com/en-us/library/aa365247(v=VS.85).aspx
        if (path[0] == '\\\\' && path[1] == '\\\\' && path[2] == '?' && path[3] == '\\\\')
            return path.ToString().Substring(4);
        else
            return path.ToString();
    }

}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll','System.Data.dll','mscorlib.dll'

$symlink_directory = 'c:\\temp\\test'
$symlink_directory_directoryinfo_object = New-Object System.IO.DirectoryInfo ($symlink_directory)
$junction_target = [utility]::GetSymbolicLinkTarget($symlink_directory_directoryinfo_object)
write-output ('junction target: {0}' -f $junction_target )

EOF
) do
    its(:exit_status) {should eq 0 }
    its(:stdout) { should match /junction target: c:\\windows\\softwareDistribution/i }
  end


  describe command( <<-EOF

# use pinvoke to read directory junction /  symlink target 
#  http://chrisbensen.blogspot.com/2010/06/getfinalpathnamebyhandle.html
Add-Type -TypeDefinition @"
// "

using System;
using System.Collections.Generic;
using System.ComponentModel; // for Win32Exception
using System.Data;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class Utility
{

    private const int FILE_SHARE_READ = 1;
    private const int FILE_SHARE_WRITE = 2;

    private const int CREATION_DISPOSITION_OPEN_EXISTING = 3;

    private const int FILE_FLAG_BACKUP_SEMANTICS = 0x02000000;

    // http://msdn.microsoft.com/en-us/library/aa364962%28VS.85%29.aspx
    // http://pinvoke.net/default.aspx/kernel32/GetFileInformationByHandleEx.html

    // http://www.pinvoke.net/default.aspx/shell32/GetFinalPathNameByHandle.html
    [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int GetFinalPathNameByHandle(IntPtr handle, [In, Out] StringBuilder path, int bufLen, int flags);

    // https://msdn.microsoft.com/en-us/library/aa364953%28VS.85%29.aspx


    // http://msdn.microsoft.com/en-us/library/aa363858(VS.85).aspx
    // http://www.pinvoke.net/default.aspx/kernel32.createfile
    [DllImport("kernel32.dll", EntryPoint = "CreateFileW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern SafeFileHandle CreateFile(string lpFileName, int dwDesiredAccess, int dwShareMode,
    IntPtr SecurityAttributes, int dwCreationDisposition, int dwFlagsAndAttributes, IntPtr hTemplateFile);

    public static string GetSymbolicLinkTarget(FileInfo symlink)
    {
        SafeFileHandle fileHandle = CreateFile(symlink.FullName, 0, 2, System.IntPtr.Zero, CREATION_DISPOSITION_OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, System.IntPtr.Zero);
        if (fileHandle.IsInvalid)
            throw new Win32Exception(Marshal.GetLastWin32Error());

        StringBuilder path = new StringBuilder(512);
        int size = GetFinalPathNameByHandle(fileHandle.DangerousGetHandle(), path, path.Capacity, 0);
        if (size < 0)
            throw new Win32Exception(Marshal.GetLastWin32Error());
        // http://msdn.microsoft.com/en-us/library/aa365247(v=VS.85).aspx
        if (path[0] == '\\\\' && path[1] == '\\\\' && path[2] == '?' && path[3] == '\\\\')
            return path.ToString().Substring(4);
        else
            return path.ToString();
    }


}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll','System.Data.dll','mscorlib.dll'


$symlink_file = 'c:\\temp\\specinfra'

$symlink_file_fileinfo_object = New-Object System.IO.FileInfo ($symlink_file)
$symlink_target = [utility]::GetSymbolicLinkTarget($symlink_file_fileinfo_object)
write-output ('symlink target: {0}' -f $symlink_target )


EOF
) do
    its(:exit_status) {should eq 0 }
    its(:stdout) { should match /symlink target: C:\\temp\\specinfra-2.43.5.gem/i }
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
context 'Inspecting Netstat' do
  # The command below is the equivalent of a linux shell command
  # ps -p $(sudo netstat -oanpt | grep $connected_port|awk '{print $7}' | sed 's|/.*||')
  describe command (<<-EOF 
$netstat_output = invoke-expression -command "cmd.exe /c netstat -ano -p TCP" ;
$connected_port = 1521
$oracle_port_listening_pid = (
$netstat_output |
  where-object  { $_ -match ":${connected_port}" } | 
    select-object -first 1 | 
      foreach-object { $fields = $_.split(" ") ; write-output ('{0}' -f $fields[-1]) })

$oracle_port_listening_pid
$oracle_port_listening_process = get-CIMInstance win32_process | where-object { $_.Processid -eq  $oracle_port_listening_pid}

write-output  $oracle_port_listening_process.commandLine

EOF
) do
    its(:stdout) { should match /TNSLSNR/io }
  end

end





# require 'spec_helper'
# does not work with windows_spec ?

# describe 'test' do
#  include_examples 'iis::init'
# end



