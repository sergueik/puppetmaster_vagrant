require_relative '../windows_spec_helper'

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

