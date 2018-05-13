require_relative '../windows_spec_helper'

context 'Loading assembly from the GAC' do
  # see also: https://github.com/zappy-shu/puppet-windowsgac	
  # https://blogs.msdn.microsoft.com/miguelnunez/2014/10/06/installing-dll-into-gac-with-powershell/ 
  # https://msdn.microsoft.com/en-us/library/system.enterpriseservices.internal.publish.gacinstall(v=vs.110).aspx
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

  # The following elementary command occasionally is throwing exceptions under specinfra
  describe command (<<-EOF
    $assembly_name = 'System.Windows.Forms'
    $assembly = [System.Reflection.Assembly]::LoadWithPartialName($assembly_name)
    write-output ($assembly.Location  -replace '\\\\', '/')
    Write-output ('FullName:{0} ' -f $assembly.GetName().FullName  )
  EOF

  ) do
    # expectations derived by running powershell snippet directly in Powershell x86
    its(:exit_status) {should eq 0 }
    # invalid backref number/name ?
    # long paths broken by newlines in output
    # its(:stdout) {should match Regexp.new('    C:/Windows/Microsoft.Net/assembly/GAC_MSIL/System.Windows.Forms/v4.0_4.0.0.0__b77a5c561934e089/System.Windows.Forms.dll') }
    its(:stdout) {should match Regexp.new('v4.0_4.0.0.0__b77a5c561934e089') }
    its(:stdout) {should contain 'FullName:System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089') }
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



