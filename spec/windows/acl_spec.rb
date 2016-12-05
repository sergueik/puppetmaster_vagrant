require_relative '../windows_spec_helper'
context 'ACLs' do
  dir = 'c:\ProgramData\Microsoft\Crypto\RSA\MachineKeys'
  context 'Command' do
    describe command ("& cacls.exe '#{dir}'") do
      # its(:stdout) { should contain 'BUILTIN\\Administrators:(OI)(CI)F' }
      its(:stdout) { should contain 'BUILTIN\\\\Administrators:F' }
    end
  end
  context 'Cmdlet' do
    describe command(<<-EOF
      $dir = '#{dir}'
      $acl = get-acl $dir
      write-output $acl.AccessToString
      $access_rules = $acl.GetAccessRules($true,$true,[System.Security.Principal.NTAccount])
      $access_rules | where-object {$_.IdentityReference.Value -match '(Everyone|BUILTIN\\Administrators)'} | select-object -property *
      <#
      NOTE: convertto-json would mangle the righs
      $access_rules | where-object {$_.IdentityReference.Value -match '(Everyone|BUILTIN\\Administrators)'} | foreach-object { write-output $_.FileSystemRights | convertto-json}
        1180063
        2032127
      #>
      $access_rules| format-list

    EOF
    ) do
      its(:stdout) { should contain 'BUILTIN\\\\Administrators Allow  FullControl' }
      [
        'FileSystemRights  : Write, Read, Synchronize',
        'FileSystemRights  : FullControl',
        'AccessControlType : Allow',
        'IdentityReference : Everyone'
      ].each do |line|
      its(:stdout) { should contain line }
      end
    end
  end
end