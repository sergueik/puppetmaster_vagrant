Enter file contents here#!/usr/bin/env ruby

require 'facter'

# http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
# http://geekswithblogs.net/akraus1/archive/2011/07/02/146056.aspx

fact_name = 'msi_query'

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
  
          
    path = 'c:\Windows\Installer\16f6d0.msi'
    property =  'UpgradeCode'
    
    setcode do 
      File.write('c:/windows/temp/test.ps1', <<-EOF
param(
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$Path,
 
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('ProductCode', 'ProductVersion', 'ProductName', 'Manufacturer', 'ProductLanguage', 'FullVersion' , 'UpgradeCode' )]
    [string]$Property
)
    try {
        # Read property from MSI database
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @($Path.FullName, 0))
        $Query = "SELECT Value FROM Property WHERE Property = '${Property}'"
        $View = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($Query))
        $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)
        $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
        $Value = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1)
 
        # Commit database and close view
        $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null)           
        $MSIDatabase = $null
        $View = $null
 
        # Return the value
        write-output ('{0}: "{1}"' -f $Property , $Value )
    } 
    catch {
        Write-Warning -Message $_.Exception.Message ; break
    }
    # Run garbage collection and release ComObject
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) | Out-Null
    [System.GC]::Collect()
      EOF
      ) 
      data_prefix = property
      data = nil
      # NOTE use double quotes with arguments
      arguments = "-Path \"#{path}\" -Property \"#{property}\""
      if output = Facter::Util::Resolution.exec("C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -file \"c:/windows/temp/test.ps1\" #{arguments}")
        # puts "output = #{output}"
        # puts "command = " +  "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -file \"c:/windows/temp/test.ps1\" #{arguments}"
        data_line = output.split("\n").grep(/#{data_prefix}/i).first       
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end 
  end
end