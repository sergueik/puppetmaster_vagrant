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
using System.Diagnostics;

public static class Program {
    [DllImport("msi.dll", SetLastError = true, CharSet = CharSet.Ansi)]
    static extern int MsiEnumProducts(int iProductIndex, StringBuilder lpProductBuf);
    [DllImport("msi.dll", CharSet = CharSet.Ansi)]
    static extern Int32 MsiGetProductInfo(string product, string property, [Out] StringBuilder valueBuf, ref Int32 len);
    public enum MSI_ERROR : int {
        ERROR_SUCCESS = 0,
        ERROR_MORE_DATA = 234,
        ERROR_NO_MORE_ITEMS = 259,
        ERROR_INVALID_PARAMETER = 87,
        ERROR_UNKNOWN_PRODUCT = 1605,
        ERROR_UNKNOWN_PROPERTY = 1608,
        ERROR_BAD_CONFIGURATION = 1610,
    }

    // https://groups.google.com/forum/#!topic/microsoft.public.platformsdk.msi/EtmjM9PdjEE
    // Product info attributes: advertised information

    public const string INSTALLPROPERTY_PACKAGENAME = "PackageName";
    public const string INSTALLPROPERTY_TRANSFORMS = "Transforms";
    public const string INSTALLPROPERTY_LANGUAGE = "Language";
    public const string INSTALLPROPERTY_PRODUCTNAME = "ProductName";
    public const string INSTALLPROPERTY_ASSIGNMENTTYPE = "AssignmentType";
    public const string INSTALLPROPERTY_PACKAGECODE = "PackageCode";
    public const string INSTALLPROPERTY_VERSION = "Version";
    public const string INSTALLPROPERTY_PRODUCTICON = "ProductIcon";


    // Product info attributes: installed information

    public const string INSTALLPROPERTY_INSTALLEDPRODUCTNAME = "InstalledProductName";
    public const string INSTALLPROPERTY_VERSIONSTRING = "VersionString";
    public const string INSTALLPROPERTY_HELPLINK = "HelpLink";
    public const string INSTALLPROPERTY_HELPTELEPHONE = "HelpTelephone";
    public const string INSTALLPROPERTY_INSTALLLOCATION = "InstallLocation";
    public const string INSTALLPROPERTY_INSTALLSOURCE = "InstallSource";
    public const string INSTALLPROPERTY_INSTALLDATE = "InstallDate";
    public const string INSTALLPROPERTY_PUBLISHER = "Publisher";
    public const string INSTALLPROPERTY_LOCALPACKAGE = "LocalPackage";
    public const string INSTALLPROPERTY_URLINFOABOUT = "URLInfoAbout";
    public const string INSTALLPROPERTY_URLUPDATEINFO = "URLUpdateInfo";
    public const string INSTALLPROPERTY_VERSIONMINOR = "VersionMinor";
    public const string INSTALLPROPERTY_VERSIONMAJOR = "VersionMajor";

    // extention method 
    public static void Clear(this StringBuilder value) {
        value.Length = 0;
        // value.Capacity = 0;
    }

    [STAThread]
    public static void Perform() {
        Int32 guidSize = 39;
        StringBuilder guidBuffer = new StringBuilder(guidSize);
        MSI_ERROR enumProductsError = MSI_ERROR.ERROR_SUCCESS;
        for (int index = 0; enumProductsError == MSI_ERROR.ERROR_SUCCESS; index++) {
            enumProductsError = (MSI_ERROR)MsiEnumProducts(index, guidBuffer);
            String guid = guidBuffer.ToString();
            if (enumProductsError == MSI_ERROR.ERROR_SUCCESS) {
                Console.WriteLine("Product GUID: " + guid);

                // extract Product Version String
                Console.Write("Product Version: ");
                // allocate sufficient size to prevent calling MsiGetProductInfo twice
                Int32 versionInfoSize = 64;
                System.Text.StringBuilder productVersionBuffer = new System.Text.StringBuilder(versionInfoSize);
		MSI_ERROR status = GetProperty (guid, "VersionString", productVersionBuffer);
                if (status == MSI_ERROR.ERROR_SUCCESS) {
                    Console.WriteLine(productVersionBuffer);
                } else {
                    Console.WriteLine("unknown");
                }
                // extract Product Name
                Console.Write("Product Name: ");
                // allocate the right size by calling the MsiGetProductInfo  two times
                System.Text.StringBuilder productNameBuffer = new System.Text.StringBuilder();
                status = GetProperty (guid, "ProductName", productNameBuffer);
                if (status == MSI_ERROR.ERROR_SUCCESS) {
                    Console.WriteLine(productNameBuffer);
                } else {
                    Console.WriteLine("unknown");
                }
            }
        }
    }
    
    // http://stackoverflow.duapp.com/questions/4013425/msi-interop-using-msienumrelatedproducts-and-msigetproductinfo
    static MSI_ERROR GetProperty(string productCode, string propertyName, StringBuilder sbBuffer) {
        int len = sbBuffer.Capacity;
        sbBuffer.Length = 0;
        MSI_ERROR status = (MSI_ERROR)MsiGetProductInfo(productCode,
                                                      propertyName,
                                                      sbBuffer, ref len);
        if (status == MSI_ERROR.ERROR_MORE_DATA) {
            len++;
            sbBuffer.EnsureCapacity(len);
            status = (MSI_ERROR)MsiGetProductInfo(productCode, propertyName, sbBuffer, ref len);
        }

        /*
        if ((status == MSI_ERROR.ERROR_UNKNOWN_PRODUCT ||
             status == MSI_ERROR.ERROR_UNKNOWN_PROPERTY)
            && (String.Compare (propertyName, "ProductVersion", StringComparison.Ordinal) == 0 ||
                String.Compare (propertyName, "ProductName", StringComparison.Ordinal) == 0)) {
            // try to get vesrion manually
            StringBuilder sbKeyName = new StringBuilder ();
            sbKeyName.Append ("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\");
            Guid guid = new Guid (productCode);
            byte[] buidAsBytes = guid.ToByteArray ();
            foreach (byte b in buidAsBytes) {
                int by = ((b & 0xf) << 4) + ((b & 0xf0) >> 4);  // swap hex digits in the byte
                sbKeyName.AppendFormat ("{0:X2}", by);
            }
            sbKeyName.Append ("\\InstallProperties");
            RegistryKey key = Registry.LocalMachine.OpenSubKey (sbKeyName.ToString ());
            if (key != null) {
                string valueName = "DisplayName";
                if (String.Compare (propertyName, "ProductVersion", StringComparison.Ordinal) == 0)
                    valueName = "DisplayVersion";
                string val = key.GetValue (valueName) as string;
                if (!String.IsNullOrEmpty (val)) {
                    sbBuffer.Length = 0;
                    sbBuffer.Append (val);
                    status = NativeMethods.NoError;
                }
            }
        }
*/
        return status;
    }
}
'@ -ReferencedAssemblies 'System.Runtime.InteropServices.dll'
      [Program]::Perform()
      EOF
      ) do
        [
          'Product GUID: ',
          "Product Name: #{appName}",
          "Product Version: #{appVersion}",
        ].each do |line|
          its(:stdout) do
            should match line
          end
        end
      end
    end
  end
end
