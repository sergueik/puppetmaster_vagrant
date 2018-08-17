require_relative '../windows_spec_helper'

context '.Net Versions' do

  # NOTE: for extensive list of the the Net Framework version registry keys and values,
  # with 4 field-granular (Major|Minor|Build|Revision) key release Version definition
  # for .NET Framework 3.0, .NET Framework 3.4  and .NET Framework 4
  # and single NetfxReleaseVersion for .NET Framework 4.5 ... 4.7.2
  # see https://www.codeproject.com/Articles/1256260/NET-Framework-Checker
  #
  context 'Powershell with Embedded C# code from MSDN' do
    # NOTE: only processes Full
    describe command(<<-'END_COMMAND'

Add-Type -TypeDefinition @"

// https://msdn.microsoft.com/en-us/library/hh925568.aspx#net_d
// https://msdn.microsoft.com/en-us/library/ff427522.aspx
using System;
using Microsoft.Win32;

public class GetCLRVersion {

    public static void Get45or451FromRegistry() {
        using (RegistryKey ndpKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32).OpenSubKey("SOFTWARE\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full\\")) {
            if (ndpKey != null && ndpKey.GetValue("Release") != null) {
                Console.WriteLine("Version: " + CheckFor45DotVersion((int)ndpKey.GetValue("Release")));
            } else {
                Console.WriteLine("Version 4.5 or later is not detected.");
            }
        }
    }

    private static string CheckFor45DotVersion(int releaseKey) {
        if (releaseKey >= 393295) {
            return "4.6 or later";
        }
        if ((releaseKey >= 379893)) {
            return "4.5.2 or later";
        }
        if ((releaseKey >= 378675)) {
            return "4.5.1 or later";
        }
        if ((releaseKey >= 378389)) {
            return "4.5 or later";
        }
        // This line should never execute. A non-null release key should mean
        // that 4.5 or later is installed.
        return "No 4.5 or later version detected";
    }
}
"@ -ReferencedAssemblies 'mscorlib.dll'

[GetCLRVersion]::Get45or451FromRegistry()

    END_COMMAND
    ) do
      its(:stdout) { should match /Version: 4.5 or later/i }
     # its(:stdout) { should match /Version: 4.5.2 or later/i }
      its(:exit_status) { should be 0 }
    end
  end
  context 'Powershell Stackoverflow example' do

    describe command(<<-END_COMMAND
# http://stackoverflow.com/questions/3487265/powershell-script-to-return-versions-of-net-framework-on-a-machine
$versions =
Get-ChildItem 'HKLM:\\SOFTWARE\\Microsoft\\NET Framework Setup\\NDP' -Recurse |
Get-ItemProperty -Name Version,Release -ErrorAction SilentlyContinue |
# Where { $_.PSChildName -match '^(?!S)\p{L}'} |
# Where-Object { -not ($_.PSChildName -match 'Setup|^\d+$') } |
# Select Full
Where-Object { $_.PSChildName -match 'Full' } |
Select PSChildName, Version, Release, @{
  name = 'Product'
  expression = {
    switch ($_.Release) {
      378389 { [version]'4.5' }
      378675 { [version]'4.5.1' }
      378758 { [version]'4.5.1' }
      379893 { [version]'4.5.2' }
      393295 { [version]'4.6' }
      393297 { [version]'4.6' }
      394254 { [version]'4.6.1' }
      394271 { [version]'4.6.1' }
    }
  }
} | convertto-json
  write-output $versions
    # added for rspec convenience

    END_COMMAND
    ) do
      [
      '"PSChildName":  "Full"',
      # '"Version":  "4.5.51650"',
      # '"Release":  379893',
      '"Version":  "4.5.50709"',
      '"Release":  378389',
      '"Major":  4',
      '"Minor":  5',
      # '"Build":  2',
      '"Build":  -1',
      ].each do |line|
        its(:stdout) { should match line }
      end
      its(:exit_status) { should be 0 }
    end
  end
end
