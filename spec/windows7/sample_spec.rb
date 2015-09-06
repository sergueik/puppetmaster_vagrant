# http://serverspec.org/resource_types.html
# https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/windows/base/iis_app_pool.rb
# specinfra-2.36.15/lib/specinfra/backend/powershell/script_helper.rb

require_relative '../windows_spec_helper'
context 'Commands' do
  describe command ('& "ipconfig" ') do
    its(:stdout) { should match /^Windows IP Configuration/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command ('(get-CIMInstance "Win32_ComputerSystem" -Property "DNSHostName").DNSHostName') do
    its(:stdout) { should match /\bwindows7\b/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command ('[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");  $f = New-Object System.Windows.Forms.Form; write-output ($f.getType().Namespace)') do
    its(:stdout) { should match /System.Windows.Forms/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command ('([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")).GetExportedTypes() |foreach-object { if ($_.Name -eq "Form") {write-output $_.NameSpace}}') do
    its(:stdout) { should match /System.Windows.Forms/ }
  end
end 
