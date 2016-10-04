require_relative '../windows_spec_helper'

context 'Version check' do
  # uses fixed version of specinfra backend command
  # https://github.com/sergueik/specinfra/blob/master/lib/specinfra/backend/powershell/support/find_installed_application.ps1
  context 'Installed Application' do
    {
     'Java 8 Update 101' => '8.0.1010.13',
    }.each do |appName, appVersion|
    describe command(<<-EOF
      function FindInstalledApplication {
        param(
          [string]$appName,
          [string]$appVersion
        )
        $DebugPreference = 'Continue'
        Write-Debug ('appName = "{0}", appVersion={1}' -f $appName,$appVersion)
        # fix to allow special character in the application names like 'Foo [Bar]'
        $appNameRegex = New-Object Regex (($appName -replace '\\[','\\[' -replace '\\]','\\]'))

        if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notmatch '64')
        {
          $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
          $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
        }
        else
        {
          $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*','HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
          $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
          $possible_path = 'HKCU:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
        }

        if ($appVersion -eq $null) {
          $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) })
          Write-Debug ('applications found:' + $result)
          Write-Output ([boolean]($result.Length -gt 0))
        }
        else {
          $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) } | Where-Object { $_.DisplayVersion -eq $appVersion })
          Write-Debug ('applications found:' + $result)
          Write-Output ([boolean]($result.Length -gt 0))
        }
      }

      $exitCode = 1
      $ProgressPreference = 'SilentlyContinue'
      try {
        $success = ((FindInstalledApplication -appName '#{appName}' -appVersion '#{appVersion}') -eq $true)
        if ($success -is [boolean] -and $success) {
          $exitCode = 0 }
      } catch {
        Write-Output $_.Exception.Message
      }
      Write-Output "Exiting with code: ${exitCode}"
    EOF
    ) do
        its(:stdout) do
          should match /Exiting with code: 0/
        end
      end
    end
  end
  context 'PInvoke msi.dll MsiEnumProducts, MsiGetProductInfo' do
    # see also:
    # http://www.pinvoke.net/default.aspx/msi.msienumproducts
    # http://www.pinvoke.net/default.aspx/msi.msigetproductinfo
    # https://github.com/gregzakh/alt-ps/blob/master/Find-MsiPackage.ps1

    # sample output:
    # ProductID = {26A24AE4-039D-4CA4-87B4-2F32180101F0}
    # ProductName = Java 8 Update 101
    # ProductVersion = 8.0.1010.13
    # NOTE: some entries do not provide information e.g.
    # ProductID = {43780CEF-4E0F-9CB3-2226-580EC6BA1ABE}
    # ProductName unknown
    # ProductVersion unknown
    {
     'Java 8 Update 101' => '8.0.1010.13',
    }.each do |appName, appVersion|
      describe command(<<-EOF
        # installed product information through MsiEnumProducts, MsiGetProductInfo

add-type -typedefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class Program
{
    [DllImport("msi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern int MsiEnumProducts(int iProductIndex, StringBuilder lpProductBuf);

    [DllImport("msi.dll", CharSet = CharSet.Unicode)]
    static extern Int32 MsiGetProductInfo(string product, string property, [Out] StringBuilder valueBuf, ref Int32 len);

    public enum MSI_ERROR : int
    {
        ERROR_SUCCESS = 0,
        ERROR_MORE_DATA = 234,
        ERROR_NO_MORE_ITEMS = 259,
        ERROR_INVALID_PARAMETER = 87,
        ERROR_UNKNOWN_PRODUCT = 1605,
        ERROR_UNKNOWN_PROPERTY = 1608,
        ERROR_BAD_CONFIGURATION = 1610,
    }

    public static void Clear(this StringBuilder value)
    {
        value.Length = 0;
        //     value.Capacity = 0;
    }

    [STAThread]
    public static void Perform()
    {
        Int32 len = 128;
        StringBuilder sb = new StringBuilder(39);
        MSI_ERROR error1 = MSI_ERROR.ERROR_SUCCESS;
        for (int index = 0; error1 == MSI_ERROR.ERROR_SUCCESS; index++)
        {
            error1 = (MSI_ERROR)MsiEnumProducts(index, sb);
            string productID = sb.ToString();
            if (error1 == MSI_ERROR.ERROR_SUCCESS)
            {
                Console.WriteLine("ProductID: " + productID);
                System.Text.StringBuilder productName = new System.Text.StringBuilder(len);
                MSI_ERROR error2 = (MSI_ERROR)MsiGetProductInfo(productID, "ProductName", productName, ref len);
                if (error2 == MSI_ERROR.ERROR_SUCCESS)
                {
                    Console.WriteLine("ProductName: " + productName);
                }
                else
                {
                    // TODO: ERROR_MORE_DATA
                    // need buffer size is returned in len
                    Console.WriteLine("ProductName: unknown");
                }
                productName.Clear();

                System.Text.StringBuilder productVersion = new System.Text.StringBuilder(len);
                MSI_ERROR error3 = (MSI_ERROR)MsiGetProductInfo(productID, "VersionString", productVersion, ref len);
                if (error3 == MSI_ERROR.ERROR_SUCCESS)
                {
                    Console.WriteLine("ProductVersion: " + productVersion);
                }
                else
                {
                    // TODO: ERROR_MORE_DATA
                    // need buffer size is returned in len
                    Console.WriteLine("ProductVersion: unknown");
                }
                productVersion.Clear();

            }
        }

    }
}
'@ -ReferencedAssemblies 'System.Runtime.InteropServices.dll'
      [Program]::Perform()
      EOF
      ) do
        [
          'ProductID: ',
          "ProductName: #{appName}",
          "ProductVersion: #{appVersion}",
        ].each do |line|
          its(:stdout) do
            should match line
          end
        end
      end
    end
  end
end
