require_relative '../windows_spec_helper'

context 'Domain Membership' do
  domain = '<DOMAIN NAME>'
  context 'WMI' do
    # https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.domain(v=vs.110).aspx
    describe command(<<-EOF
      $o = get-wmiobject -class Win32_ComputerSystem
      if ($o.PartOfDomain -eq  $true ) {
        # write-output ('domain: {0}' -f ( [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()))
        # Exception calling "GetCurrentDomain" with "0" argument(s): "Current security context is not associated with an ActiveDirectory domain or forest."
        write-output ('domain: {0}' -f $o.Domain )
      } else {
        write-output ('workgroup: {0}' -f $o.workgroup )
        # not in the domain
      }
    EOF
    ) do
      its(:stdout) { should match /domain: #{domain}/i }
    end
  end
  context 'win32 call' do
    # based on
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724301%28v=vs.85%29.aspx
    # http://www.pinvoke.net/default.aspx/kernel32.getcomputernameex
    # http://msdn.microsoft.com/en-us/library/ms724224(v=vs.85).aspx
    # https://github.com/oscar-stack/vagrant-hosts/pull/49/files
    # http://poshcode.org/2958
    # http://poshcode.org/6640
    describe command(<<-EOF
      Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public class ComputerName {
    enum COMPUTER_NAME_FORMAT
    {
        ComputerNameNetBIOS,
        ComputerNameDnsHostname,
        ComputerNameDnsDomain,
        ComputerNameDnsFullyQualified,
        ComputerNamePhysicalNetBIOS,
        ComputerNamePhysicalDnsHostname,
        ComputerNamePhysicalDnsDomain,
        ComputerNamePhysicalDnsFullyQualified
    }

    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    static extern bool GetComputerNameEx(COMPUTER_NAME_FORMAT NameType,
        StringBuilder lpBuffer, ref uint lpnSize);

    [STAThread]
    static public void Report()
    {
        bool success;
        StringBuilder name = new StringBuilder(260);
        uint size = 260;
        success = GetComputerNameEx(COMPUTER_NAME_FORMAT.ComputerNameDnsDomain, name, ref size);
        Console.WriteLine(String.Format("domain name = {0}" , name.ToString()));
    }
     }
'@  -ReferencedAssemblies 'System.Runtime.InteropServices.dll','System.Net.dll'
      [ComputerName]::Report()
    EOF
    ) do
      its(:stdout) { should match /domain name = #{domain}/i }
    end
  end
end
