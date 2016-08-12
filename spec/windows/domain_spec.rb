require_relative '../windows_spec_helper'

context 'Domain Membership' do
  domain = '<DOMAIN NAME>'
  describe command(<<-END_COMMAND
$o = get-wmiobject -class Win32_ComputerSystem
if ($o.PartOfDomain -eq  $true ) {
  # https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.domain(v=vs.110).aspx
  # write-output ('domain: {0}' -f ( [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()))
  # Exception calling "GetCurrentDomain" with "0" argument(s): "Current security context is not associated with an ActiveDirectory domain or forest."
  write-output ('domain: {0}' -f $o.Domain )
} else {
  write-output ('workgroup: {0}' -f $o.workgroup )
  # not in the domain
}
END_COMMAND
) do
    its(:stdout) { should match /domain: #{domain}/i }
  end
end
