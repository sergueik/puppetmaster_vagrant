require_relative '../windows_spec_helper'

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

