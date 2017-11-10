require_relative '../windows_spec_helper'
default = {   'property' => 'overrideMode',  'value' => 'Allow'}

{
  '//system.webServer/modules' => {
    'value' => 'Allow', 'property' => 'overrideMode'
    },
'//system.webServer/handlers' => { 
    'value' =>'Allow' 
  },
  '//system.webServer/isapiFilters' => 'ignored',  
  '//system.webServer/httpErrors ' => nil,  
}.each do |xpath,data|
  if data.kind_of?(Hash) && data.respond_to?(:has_key?)
    value = data.has_key?('value') ? data['value'] : default['value']
    property = data.has_key?('property') ? data['property'] : default['property']
  else
    value = default['value']
    property = default['property']
  end
  describe command (<<-EOF
    $xpath = '#{xpath}'
    $property = '#{property}'
    Import-Module ServerManager
    Get-WebConfiguration $xpath iis:\\ |
    select $property -ExpandProperty $property
  EOF
  ) do
    let(:path) { "c:\\"}
    its(:stdout) { should match /#{value}/i }
    its(:stderr) { should be_empty }
    its(:exit_status){should eq 0 }
  end
end
describe command ("powershell.exe -Command \"Import-Module ServerManager; Get-WebConfiguration //system.webServer/handlers iis:\\ | select overrideMode -ExpandProperty overrideMode\"") do
  let(:path) { "c:\\"}
  its(:stdout) { should match /Allow/ }
  its(:stderr) { should be_empty }
  its(:exit_status) {should eq 0 }
end

# NOTE  different cmdlet
describe command (<<-EOF
powershell.exe -Command "Import-Module ServerManager; Get-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -Name enabled"

EOF
) do
  let(:path) { "c:\\"}
  its(:stdout) { should match /True/ }
  its(:stderr) { should be_empty }
  its(:exit_status) {should eq 0 }
end
