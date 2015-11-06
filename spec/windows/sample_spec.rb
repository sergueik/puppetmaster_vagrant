require_relative '../windows_spec_helper'

context 'Commands' do
  context 'basic' do
    processname = 'csrss'
    describe command("(get-process -name '#{processname}').Responding") do
      let (:pre_command) { 'get-item -path "c:\windows"' }
      its(:stdout) { should match /[tT]rue/ }
      its(:exit_status) { should eq 0 }
    end
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
  context 'Hotfix' do
    describe command(<<-END_COMMAND
 $hot_fix_id = 'KB976932'
 $keys = (get-wmiobject -class 'win32_quickfixengineering')
 $status = (@($keys | where-object { $_.hotfixid -eq $hot_fix_id } ).length -gt 0 )
write-output $status 
if ($status -is [Boolean] -and $status){ $exit_code = 0 } else { $exit_code = 1 } 
exit $exit_code
END_COMMAND
) do
      its(:stdout) { should match /true/i }
      its(:exit_status) { should == 0 } 
    end
    describe windows_hot_fix('KB976932') do
      it { should be_installed }
    end 
  end
  context 'medium complex' do
    describe command(<<-END_COMMAND
  write-output 'main command testing the status of pre_command success';
exit 0;
END_COMMAND
) do
      let (:pre_command) do 
        #NOTE: cannot make assignments inside [ScriptBlock]::Create
        # overall looks ugly and brittle
        pre_command =  <<-END
( Invoke-Command -ScriptBlock ([Scriptblock]::Create("write-host 'pre-command'; write-host 'return true'; $return $true"))) -eq $true 
END
        pre_command.gsub!(/\r?\n/,' ')
      end
      its(:stdout) { should match /pre-command/ }
      its(:stdout) { should match /success/ }
      its(:stderr) { should match /success/ }
      its(:exit_status) { should eq 0 }
    end
  end
  context 'download .net assembly for execution' do
      @url =  'http://github.com/nunit/nunitv2/releases/download/2.6.4/NUnit-2.6.4.zip' 
      @download_path =  'c:/temp' 
      @file =  'nunit.zip' 
    describe command(<<-END_COMMAND
write-output 'pre_command was success';
write-output 'main command is run';

write-output 'Check the file is present'
\$zip_path = '#{@download_path}/#{@file}'
test-path -LiteralPath \$zip_path -ErrorAction Stop
write-output 'extract the file'
[string]\$extract_path = ('{0}\\Desktop\\Extract' -f \$env:USERPROFILE)
[System.IO.Directory]::CreateDirectory(\$extract_path)
add-type  -AssemblyName 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::ExtractToDirectory(\$zip_path, \$extract_path)
\$dll_name = 'nunit.framework.dll'
write-output 'load assembly'
add-type -path ('{0}\\Desktop\\Extract\\NUnit-2.6.4\\bin\\{1}' -f \$env:USERPROFILE , \$dll_name)
write-output 'throw assertion exception'
[NUnit.Framework.Assert]::IsTrue(\$true -eq \$false)
write-output 'complete execution'
return \$true
END_COMMAND
) do
# NOTE: avoid using \$true - too much interpolation
      let(:pre_command_script) { "(new-object -typename 'System.Net.WebClient').DownloadFile('#{@url}','#{@download_path}/#{@file}'); write-host 'return -1'; return -1" }
      let (:pre_command) do 
      #NOTE: cannot make assignments inside [ScriptBlock]::Create
      # overall looks ugly and brittle
      pre_command =  <<-END
( Invoke-Command -ScriptBlock ([Scriptblock]::Create("#{pre_command_script}"))) -eq -1 
END
      pre_command.gsub!(/\r?\n/,' ')
      end
      its(:stdout) { should match /main command/ }
      its(:stdout) { should match /pre_command/ }
      its(:stdout) { should match /extract the file/ }
      its(:stdout) { should match /load assembly/ }
      its(:stdout) { should match /throw assertion exception/ }
      its(:stdout) { should match /complete execution/ }
      its(:stderr) { should match /Exception/ }
      its(:stderr) { should match /Expected: True/ }
      its(:stderr) { should match /But was:  False/ }
      its(:exit_status) { should == 1 } 
    end
  end
end

require_relative '../windows_spec_helper'

context 'Commands' do
  context 'Download and execute .net assembly for testing of the system' do
    assembly_url =  'http://github.com/nunit/nunitv2/releases/download/2.6.4/NUnit-2.6.4.zip' 
    zip_download_path =  'c:/temp' 
    zip_filename =  'nunit.zip' 
    dll_name = 'nunit.framework.dll'
    describe command(<<-END_COMMAND
$dll_name = '#{dll_name}'
$zip_download_path="#{zip_download_path}"
$assembly_url = '#{assembly_url}'
$zip_filename = '#{zip_filename}'
$zip_fullname = "${zip_download_path}/${zip_filename}"
write-output ('Download "{0}" to "{1}"' -f $assembly_url, $zip_fullname)
(new-object -typename 'System.Net.WebClient').DownloadFile($assembly_url,$zip_fullname)

write-output 'Check the file is present'
test-path -LiteralPath $zip_fullname -ErrorAction Stop
write-output 'extract the file'
[string]$extract_path = ('{0}\\Desktop\\Extract' -f $env:USERPROFILE)
[System.IO.Directory]::CreateDirectory($extract_path)
$o = New-Object -COM 'Shell.Application'
$o.namespace((Convert-Path $extract_path)).Copyhere($o.namespace((Convert-Path $zip_fullname)).items(), 16)

write-output ('Load assembly' -f $dll_name)
add-type -path ('{0}\\NUnit-2.6.4\\bin\\{1}' -f $extract_path, $dll_name)
write-output 'Throw sample assertion exception'
[NUnit.Framework.Assert]::IsTrue($true -eq $false)
write-output 'Complete execution'

END_COMMAND
) do
      
      its(:stdout) { should match /Extract the file/i }
      its(:stdout) { should match /Load assembly/i }
      its(:stdout) { should match /Throw sample assertion exception/i }
      its(:stdout) { should match /Complete execution/i }
      its(:stderr) { should match /Exception/ }
      its(:stderr) { should match /Expected: True/ }
      its(:stderr) { should match /But was:  False/ }
      its(:exit_status) { should == 1 } 
    end
  end
end
context 'Shortcuts' do
  link_basename = 'puppet_test'
  link_basename = 'puppet_test(admin)'
  link_hexdump  = "c:/windows/temp/#{link_basename}.hex"
 
  before(:all) do
    Specinfra::Runner::run_command(<<-END_COMMAND
$link_basename = '#{link_basename}'
$link_hexdump = '#{link_hexdump}'

Get-Content "$HOME\\Desktop\\${link_basename}.lnk" -Encoding Byte -ReadCount 256 | ForEach-Object {
  $output = ''
  foreach ( $byte in $_ ) {
    $output += '{0:X2} ' -f $byte
  }
  write-output $output | out-file $link_hexdump -append
}
END_COMMAND
)
  end
  describe file(link_hexdump) do
    # HeaderSize
    its(:content) { should match /4C 00 00 00/ }
    # LinkCLSID
    its(:content) { should match /01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46/ }
  end
  describe command(<<-END_COMMAND
$link_basename = '#{link_basename}'
[byte[]] $bytes = get-content -encoding byte -path "$env:USERPROFILE\\Desktop\\${link_basename}.lnk" -totalcount 20
  foreach ( $byte in $bytes ) {
    $output += '{0:X2} ' -f $byte
  }
write-output $output 
END_COMMAND
) do
    # HeaderSize
    its(:stdout) { should match /4C 00 00 00/ }
    # LinkCLSID
    its(:stdout) { should match /01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46/ }
  end
end
context 'Registry' do
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

context 'multistring' do
# run the same script before(:all) does not help
before(:all) do
  Specinfra::Runner::run_command(<<-END_COMMAND
$registry_key  = 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\Appinfo' 
$property = 'DependOnService'
(Get-Item $registry_key).GetValue($property)
END_COMMAND
  ) 
  end
  processname = 'csrss'
  registry_key  = 'HKLM:\SYSTEM\CurrentControlSet\services\Appinfo' 
  testdata  = {
      'DependOnService' => "RpcSs\nProfSvc",
      'RequiredPrivileges' => "SeBackupPrivilege\nSeTcbPrivilege",
    }
  testdata.each do |property,values|
    describe command (<<-END_COMMAND
$registry_key = '#{registry_key}'
$property = '#{property}'
$values = @"
#{values}
"@
$status = $true
$values -split "`r?`n" | foreach-object {
$value = $_ 
$value = $value -replace '^.*\\\\', ''
$status = $status -band [bool] ((Get-Item $registry_key).GetValue($property) -match $value )
}
write-output ([bool]$status)
$exit_status  = [int](-not $status )

write-output "exiting with ${exit_status}"

exit( $exit_status)
END_COMMAND
    ) do
        its(:stdout) { should match /true/i }
        its(:stdout) { should match /exiting with 0/i }
        # sporadically collecting the <AV>Preparing modules for first use.</AV> error
        its(:exit_status) {should eq 0} 
    end
  end
end
# TODO:
#    'RequiredPrivileges' => [ 'SeAssignPrimaryTokenPrivilege', 'SeIncreaseQuotaPrivilege', 'SeTcbPrivilege', 'SeBackupPrivilege', 'SeRestorePrivilege', 'SeDebugPrivilege', 'SeAuditPrivilege', 'SeChangeNotifyPrivilege', 'SeImpersonatePrivilege' ], 

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
    it { should have_property('StartName') }
    # it { should have_property('StartName','LocalSystem') }

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
context 'ports' do
      @executable =  'svchost' 
    describe command(<<-END_COMMAND
    \$process_id = (get-wmiobject -computername '.' -query "select name, processid from win32_process where name like '#{@executable}%'").processid
$status  = -1
$listening_ports = @()
`c:\\windows\\system32\\netstat.exe -ano -p TCP` |
foreach-object { $fields = ($_ -replace ' ' , '/') -split '/' 
$listening_process_id = $fields[-1]
$listening_socket = $fields[2]
if ($listening_process_id -eq $process_id) {
  $status  = 0
  $listening_ports+= ($listening_socket -replace '[\\d.]+:', '')
 }
} 
write-output ($listening_ports -join ',')
return $status
END_COMMAND
) do
      its(:stdout) { should match /([\d],?)+/ }
      its(:exit_status) { should == 0 } 
    end
end
context 'chained commands' do
  context 'basic' do
    before(:each) do
      # interpolation
      # Specinfra::Runner::run_command("echo \"it works\" > #{@logfile}")
      Specinfra::Runner::run_command("echo \"it works\" > c:\\temp\\a.txt")
    end
    @logfile = 'c:\temp\a.txt'
    describe command("(get-content -path '#{@logfile}')") do
      its(:stdout) { should match /it works/ }
      its(:exit_status) { should eq 0 }
    end
  end
  context 'moderate' do
    context 'download .net assembly for execution' do
      @url =  'http://github.com/nunit/nunitv2/releases/download/2.6.4/NUnit-2.6.4.zip' 
      @download_path =  'c:/temp' 
      @file =  'nunit.zip' 
      before(:each) do 
       Specinfra::Runner::run_command(<<-END_COMMAND1
\$o = new-object -typename 'System.Net.WebClient'
\$o.DownloadFile('#{@url}','#{@download_path}/#{@file}')
END_COMMAND1
)
      end
      describe command(<<-END_COMMAND

write-output 'Check the file is present'
\$zip_path = '#{@download_path}/#{@file}'
test-path -LiteralPath \$zip_path -ErrorAction Stop
write-output 'extract the file'
[string]\$extract_path = ('{0}\\Desktop\\Extract' -f \$env:USERPROFILE)
[System.IO.Directory]::CreateDirectory(\$extract_path)
add-type  -AssemblyName 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::ExtractToDirectory(\$zip_path, \$extract_path)
\$dll_name = 'nunit.framework.dll'
write-output 'load assembly'
add-type -path ('{0}\\Desktop\\Extract\\NUnit-2.6.4\\bin\\{1}' -f \$env:USERPROFILE , \$dll_name)
write-output 'throw assertion exception'
[NUnit.Framework.Assert]::IsTrue(\$true -eq \$false)
write-output 'complete execution'
return \$true
END_COMMAND
) do
      its(:stdout) { should match /extract the file/ }
      its(:stdout) { should match /load assembly/ }
      its(:stdout) { should match /throw assertion exception/ }
      its(:stdout) { should match /complete execution/ }
      its(:stderr) { should match /Exception/ }
      its(:stderr) { should match /Expected: True/ }
      its(:stderr) { should match /But was:  False/ }
      # its(:exit_status) { should == 1 } 
      end
    end
  end
end
