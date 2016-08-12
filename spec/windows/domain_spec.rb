require_relative '../windows_spec_helper'

context 'Domain Membership' do
  domain = 'domain_name'
  describe command(<<-END_COMMAND

if (( get-wmiobject -class Win32_ComputerSystem).PartOfDomain -eq  $true){
  write-output ('domain: {0}' -f ( [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()))
  write-output ('domain: {0}' -f ( get-wmiobject -class Win32_ComputerSystem).Domain ))
} else { 

  write-output ( ( get-wmiobject -class Win32_ComputerSystem).workgroup )
  # not in the domain 
} 

END_COMMAND
) do
    its(:stdout) { should match /domain: #{domain}/i }
  end
end
