require_relative '../windows_spec_helper'

context 'Symbolic Links' do

  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
    pushd 'c:/temp'
    mkdir 'directory_target' -erroraction 'silentlycontinue'
    touch 'file_target'
    cmd %%- /c mklink /D 'directory_link' 'directory_target'
    cmd %%- /c mklink /D 'file_link' 'file_target'
    cmd %%- /c mklink /J 'directory_junction' 'directory_target'
  EOF
  ) end

  context 'Requires custom specinfra' do
    describe file('c:/temp/directory_link') do
      it { should be_symlink }
    end
  end
  context 'Powershell v5.0' do
    symlink_path = 'C:/temp/directory_link'
    symlink_parent_path = 'c:/temp'
    describe command(<<-EOF
      $symlink_parent_path = '#{symlink_parent_path}' -replace '/' , '\\'
      (get-childitem $symlink_parent_path | where-object { $_.LinkType -eq 'SymbolicLink' }).Target
    EOF
    ) do
      its(:stdout) { should match Regexp.new('directory_target') }
    end
  end
  context 'Powershell' do
    # https://docs.microsoft.com/en-us/windows/desktop/shell/shellfolderitem-extendedproperty
    # To see all defined properties of ShellFolderItem, use snippet from
    # https://jamesone111.wordpress.com/2008/12/09/borrowing-from-windows-explorer-in-powershell-part-2-extended-properties/
    # $shell = new-object -ComObject Shell.Application
    # $folder = $shell.namespace("${env:userprofile}\Desktop")
    # 0..266 | foreach {'{0,3}:{1}' -f $_,$folder.getDetailsOf($null, $_)}
    # will gives:
    # 194:Link target
    symlink_path = 'C:/temp/directory_link'
    symlink_parent_path = 'c:/temp'
    describe command(<<-EOF
      $symlink_path = '#{symlink_path}' -replace '/' , '\\'
      (new-object -ComObject 'Shell.Application').NameSpace(0).ParseName($symlink_path).ExtendedProperty('LinkTarget')
    EOF
    ) do
      its(:stdout) { should match Regexp.new('directory_target') }
    end
  end
  context 'Fsutil' do
    # http://www.cyberforum.ru/powershell/thread2312694.html
    # NOTE: the FSUTIL utility requires that you have administrative privileges 
    symlink_path = 'C:/temp/directory_link'
    symlink_parent_path = 'c:/temp'
    describe command(<<-EOF
      $symlink_path = '#{symlink_path}' -replace '/' , '\\'
      cmd %%- /c fsutil.exe reparsepoint query $symlink_path| findstr /rc:" [A-z\\][^?.]"
    EOF
    ) do
      its(:stdout) { should match Regexp.new('Symbolic Link') }
    end
  end
  context 'CMD' do
    symlink_path = 'C:/temp/directory_link'
    symlink_parent_path = 'c:/temp'
    describe command(<<-EOF
      $symlink_parent_path = '#{symlink_parent_path}' -replace '/' , '\\'
      cmd %%- /c dir /A:L $symlink_parent_path
    EOF
    ) do
      its(:stdout) { should match Regexp.new('directory_target') }
    end
  end

  context 'Parsing cmd output' do

    symlink_path = 'c:\Temp\directory_link'
    target_path = 'c:\temp\directory_target'
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

  # TODO: API to read directory junction target
  function Get-DirectoryJunctionTarget([string]$test_path) {

    $command = ('cmd /c dir /L /-C "{0}"' -f
                [System.IO.Directory]::GetParent($test_path ))
    $capturing_match_expression = ( '<(?:JUNCTION|SYMLINKD|SYMLINK)>\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f
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

  # TODO:  API to read symlink target
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
  $symlink_path = '#{symlink_path}'
  $is_junction = Test-DirectoryJunction -test_path $symlink_path
  write-output ('is junction: {0}' -f $is_junction )

  $junction_target = Get-DirectoryJunctionTarget  -test_path $symlink_path
  write-output ('junction target: {0}' -f $junction_target )

  $is_symlink = Test-Symlink -test_path 'c:\\temp\\directory_link'
  write-output ('is symlink: {0}' -f $is_symlink )

  $symlink_target = Get-SymlinkTarget  -test_path 'c:\\temp\\directory_link'
  write-output ('symlink target: {0}' -f $symlink_target )

  EOF
  ) do
      its(:exit_status) {should eq 0 }
      # dependent on the kind of the link either 'is junction: True'  or 'is symlink: True' will be printed
      # its(:stdout) { should match /is symlink: True/  }
      # its(:stdout) { should match /symlink target: directory_target/i   }
      its(:stdout) { should match /is junction: True/  }
      its(:stdout) { should match /junction target: c:\\temp\\directory_target/i   }
    end
  end

  # Powershell 5.0 supports creating and detecting of symbolic link directly
  context 'Powershell 5.0' do
    symlink_path = 'c:\Temp\directory_link'
    target_path = 'c:\temp\directory_target'
    before(:each) do

      Specinfra::Runner::run_command( <<-END_COMMAND
        $target_path = '#{target_path}'
        $symlink_path = '#{symlink_path}'
        $target_parent_path = $target_path -replace '\\\\[^\\\\]+$',''
        $target_directory_name = $target_path -replace '^.+\\\\',''
        pushd $target_parent_path
        New-Item -ItemType Directory -Name $target_directory_name -ErrorAction SilentlyContinue
        popd
        if (Test-Path -Path $symlink_path) {
          # NOTE: Powershell will warn you
          # remove-item : C:\temp\#{symlink_path} is an NTFS junction point.
          # Use the Force parameter to delete or modify this object.
          Remove-Item -Path $symlink_path -Force
        }
        $symlink_parent_path = $symlink_path -replace '\\\\[^\\\\]+$',''
        $symlink_directory_name = $symlink_path -replace '^.+\\\\',''
        pushd $target_parent_path
        # NOTE: Powershell will warn you
        # New-Item : Administrator privilege required for this operation.
        New-Item -ItemType SymbolicLink -Name "${symlink_directory_name}" -Target $target_path
        popd
      END_COMMAND
      )
    end

    describe command( <<-EOF
    $symlink_path = '#{symlink_path}'
    get-item -path $symlink_path | select-object -property 'LinkType' | format-list
    get-item -path $symlink_path | select-object -expandproperty 'Target'
  EOF
  ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /LinkType\s+:\s+SymbolicLink/  }
      its(:stdout) { should contain Regexp.new(target_path) }
    end
  end

  context 'Directory Junctions and Reparse Points' do
    # use pinvoke to read directory junction /  symlink target
    # http://chrisbensen.blogspot.com/2010/06/getfinalpathnamebyhandle.html
    describe command( <<-EOF
      Add-Type -TypeDefinition @"
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

      $junction_directory = 'c:\\temp\\directory_junction'
      $junction_directory_directoryinfo_object = New-Object System.IO.DirectoryInfo ($junction_directory)
      $junction_target = [utility]::GetSymbolicLinkTarget($junction_directory_directoryinfo_object)
      write-output ('junction target: {0}' -f $junction_target )

      EOF
      ) do
          its(:exit_status) {should eq 0 }
          its(:stdout) { should match /junction target: c:\\temp\\directory_target/i }
        end


    describe command( <<-EOF

  # use pinvoke to read directory junction / symlink target
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

  $symlink_file = 'c:\\temp\\file_link'

  $symlink_file_fileinfo_object = New-Object System.IO.FileInfo ($symlink_file)
  $symlink_target = [utility]::GetSymbolicLinkTarget($symlink_file_fileinfo_object)
  write-output ('symlink target: {0}' -f $symlink_target )
  EOF
  ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /symlink target: C:\\temp\\file_target/i }
    end
  end

  # origin: https://raw.githubusercontent.com/guitarrapc/PowerShellUtil/master/SymbolicLink/Get-SynbolicLink.ps1
  # https://msdn.microsoft.com/en-us/library/system.io.fileattributes%28v=vs.110%29.aspx

  context 'Powershell calling C# SymbolicLink' do
    link_name = 'C:\temp\directory_link'
    describe command(<<-EOF
      [System.IO.File]::GetAttributes([System.IO.FileInfo]($file_reparsepoint_link))
      # Archive, ReparsePoint, NotContentIndexed
       [System.IO.File]::GetAttributes([System.IO.DirectoryInfo]($regular_directory))
      # Directory, NotContentIndexed
       [System.IO.File]::GetAttributes([System.IO.DirectoryInfo]($directory_reparsepoint_link))
      # Directory, ReparsePoint, NotContentIndexed
      $expected = @([System.IO.FileAttributes]::Archive, [System.IO.FileAttributes]::ReparsePoint,, [System.IO.FileAttributes]::NotContentIndexed ) -join ', '
      #Archive, ReparsePoint, NotContentIndexed
    EOF
    ) do
      its(:exit_status) {should eq 0 }
    end
  end

end