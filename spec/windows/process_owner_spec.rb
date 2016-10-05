require_relative '../windows_spec_helper'

# A verbose alternative to
# https://blogs.technet.microsoft.com/heyscriptingguy/2015/02/27/get-process-owner-and-other-info-with-wmi-and-powershell/

# origin : http://www.pinvoke.net/default.aspx/advapi32.openprocesstoken
# http://www.pinvoke.net/default.aspx/advapi32.gettokeninformation
# http://stackoverflow.com/questions/8419710/how-to-use-psapi-to-get-process-list-in-c

# http://stackoverflow.com/questions/499053/how-can-i-convert-from-a-sid-to-an-account-name-in-c-sharp
# http://www.java2s.com/Code/CSharp/Security/Convertbytearraytosidstring.htm
# https://bytes.com/topic/c-sharp/answers/225065-how-call-win32-native-api-gettokeninformation-using-c
  
# see also: https://github.com/gregzakh/alt-ps/blob/master/Get-ProcessOwner.ps1
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa379634%28v=vs.85%29.aspx

context 'Owner' do

  context 'WMI' do
    # this is practically identical to what
    # https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/windows/base/process.rb
    # is doing
    name = 'ruby.exe'
    describe command(<<-EOF
      $name =  '#{name}'
      $win32_process = Get-CimInstance Win32_Process -Filter "name = '${name}'" | select-object -first 1
      $owner = Invoke-CimMethod -InputObject $win32_process -MethodName GetOwner
      write-output (@($name, $owner.'Domain', $owner.'User') |  format-list )    
    EOF
    ) do
      [
      'ruby.exe',
      'NT AUTHORITY',
      'SYSTEM'
      ].each do |line| 
        its(:stdout) { should match /#{line}/io }
      end
    end
  end
  context 'P Invoke' do
    name = 'ruby.exe'
    describe command (<<-EOF
      Add-Type -TypeDefinition @"

        using System.Diagnostics;
        using System.Globalization;
        using System.Security.Principal;
        using System;
        using Microsoft.Win32.SafeHandles;
        using System.Runtime.InteropServices;
        using System.Collections.Generic;
        using System.Text;
        using System.IO;

        public class Test
            {
                [DllImport("advapi32.dll", SetLastError = true)]
                public static extern bool OpenProcessToken(IntPtr ProcessHandle, UInt32 DesiredAccess, out IntPtr TokenHandle);
                private static uint STANDARD_RIGHTS_REQUIRED = 0x000F0000;
                private static uint STANDARD_RIGHTS_READ = 0x00020000;
                private static uint TOKEN_ASSIGN_PRIMARY = 0x0001;
                private static uint TOKEN_DUPLICATE = 0x0002;
                private static uint TOKEN_IMPERSONATE = 0x0004;
                private static uint TOKEN_QUERY = 0x0008;
                private static uint TOKEN_QUERY_SOURCE = 0x0010;
                private static uint TOKEN_ADJUST_PRIVILEGES = 0x0020;
                private static uint TOKEN_ADJUST_GROUPS = 0x0040;
                private static uint TOKEN_ADJUST_DEFAULT = 0x0080;
                private static uint TOKEN_ADJUST_SESSIONID = 0x0100;
                private static uint TOKEN_READ = (STANDARD_RIGHTS_READ | TOKEN_QUERY);
                private static uint TOKEN_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED | TOKEN_ASSIGN_PRIMARY |
                    TOKEN_DUPLICATE | TOKEN_IMPERSONATE | TOKEN_QUERY | TOKEN_QUERY_SOURCE |
                    TOKEN_ADJUST_PRIVILEGES | TOKEN_ADJUST_GROUPS | TOKEN_ADJUST_DEFAULT |
                    TOKEN_ADJUST_SESSIONID);

                public struct TOKEN_USER
                {
                    public SID_AND_ATTRIBUTES User;
                }

                [StructLayout(LayoutKind.Sequential)]
                public struct SID_AND_ATTRIBUTES
                {

                    public IntPtr Sid;
                    public int Attributes;
                }

        public static string ConvertBytesToSidString(byte[] sidBytes)
            {
                string sid = String.Empty;
                sid = new SecurityIdentifier(sidBytes, 0).ToString();
                return sid;
            }
                [DllImport("advapi32.dll", SetLastError = true)]
                public static extern bool GetTokenInformation(IntPtr TokenHandle, TOKEN_INFORMATION_CLASS TokenInformationClass, IntPtr TokenInformation, uint TokenInformationLength, out uint ReturnLength);
                public enum TOKEN_INFORMATION_CLASS
                {
                    TokenUser = 1,
                    TokenGroups,
                    TokenPrivileges,
                    TokenOwner,
                    TokenPrimaryGroup,
                    TokenDefaultDacl,
                    TokenSource,
                    TokenType,
                    TokenImpersonationLevel,
                    TokenStatistics,
                    TokenRestrictedSids,
                    TokenSessionId,
                    TokenGroupsAndPrivileges,
                    TokenSessionReference,
                    TokenSandBoxInert,
                    TokenAuditPolicy,
                    TokenOrigin
                }

                public static byte[] GetSIDByteArr(IntPtr processHandle)
                {
                    int MAX_INTPTR_BYTE_ARR_SIZE = 512;
                    IntPtr tokenHandle;
                    byte[] sidBytes;

                    // Get the Process Token
                    
                    if (!OpenProcessToken(processHandle, /* DesiredAccess */ TOKEN_READ|TOKEN_QUERY|TOKEN_ADJUST_PRIVILEGES, out tokenHandle))
                        throw new ApplicationException("Could not get process token.  Win32 Error Code: " + Marshal.GetLastWin32Error());

                    uint tokenInfoLength = 0;
                    bool result;
                    result = GetTokenInformation(tokenHandle, TOKEN_INFORMATION_CLASS.TokenUser, IntPtr.Zero, tokenInfoLength, out tokenInfoLength);  // get the token info length
                    IntPtr tokenInfo = Marshal.AllocHGlobal((int)tokenInfoLength);
                    result = GetTokenInformation(tokenHandle, TOKEN_INFORMATION_CLASS.TokenUser, tokenInfo, tokenInfoLength, out tokenInfoLength);  // get the token info

                    // Get the User SID
                    if (result)
                    {
                        TOKEN_USER tokenUser = (TOKEN_USER)Marshal.PtrToStructure(tokenInfo, typeof(TOKEN_USER));
                        sidBytes = new byte[MAX_INTPTR_BYTE_ARR_SIZE];  // Since I don't yet know how to be more precise w/ the size of the byte arr, it is being set to 512
                        Marshal.Copy(tokenUser.User.Sid, sidBytes, 0, MAX_INTPTR_BYTE_ARR_SIZE);  // get a byte[] representation of the SID
                    }
                    else throw new ApplicationException("Could not get process token.  Win32 Error Code: " + Marshal.GetLastWin32Error());
                    return sidBytes;
                }

                public string Owner(IntPtr handle)
                {
                    byte[] sidBytes = GetSIDByteArr(handle);
                    String sid = ConvertBytesToSidString(sidBytes);
                    String account = new System.Security.Principal.SecurityIdentifier(sid).Translate(typeof(System.Security.Principal.NTAccount)).ToString();
                    return account;
                }
                public Test()
                {
                }

        }
"@ -ReferencedAssemblies 'mscorlib.dll'
    $o =  new-object -type Test
    $name =  '#{name.gsub(/\..*$/,'')}'
    $process = Get-Process -Name $name
    write-output $process
    $owner = $o.Owner($process.Handle) 
    write-output (@($name, $owner) | format-list )
    EOF
    ) do
      [
      'ruby.exe',
      'NT AUTHORITY',
      'SYSTEM'
      ].each do |line| 
        its(:stdout) { should match /#{line}/io }
      end
      # Exception calling "Owner" with "1" argument(s): "Could not get process token. Win32 Error Code: 5"
      # https://msdn.microsoft.com/en-us/library/cc231199.aspx
      # 0x00000005
      # ERROR_ACCESS_DENIED
      its(:stderr) { should be_empty }
    end
  end
end
