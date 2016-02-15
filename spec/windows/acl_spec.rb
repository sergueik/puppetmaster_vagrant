require_relative '../windows_spec_helper'
context 'ACLs' do
  dir = 'c:\ProgramData\Microsoft\Crypto\RSA\MachineKeys'
  describe command ("& cacls '#{dir}'") do
    # its(:stdout) { should contain 'BUILTIN\\Administrators:(OI)(CI)F' }
    its(:stdout) { should contain 'BUILTIN\\\\Administrators:F' }
  end
  describe command(<<-EOF
  $path = '#{dir}'
  $acl = get-acl $path
  $acl.AccessToString 
  EOF
  ) do
    its(:stdout) { should contain 'BUILTIN\\\\Administrators Allow  FullControl' } 
  end 
end
