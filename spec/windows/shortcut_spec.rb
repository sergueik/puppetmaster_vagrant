require_relative '../windows_spec_helper'

context 'Shortcuts' do
  link_basename = 'puppet_test'
  link_basename = 'puppet_test(admin)'
  link_hexdump  = "c:/windows/temp/#{link_basename}.hex"
 
  before(:all) do
    Specinfra::Runner::run_command(<<-END_COMMAND
$link_basename = '#{link_basename}'
$link_hexdump = '#{link_hexdump}'

Get-Content "$HOME\\Desktop\\${link_basename}.lnk" -Encoding Byte -ReadCount 256 | ForEach-Object {
  $output = ''
  foreach ( $byte in $_ ) {
    $output += '{0:X2} ' -f $byte
  }
  write-output $output | out-file $link_hexdump -append
}
END_COMMAND
)
  end
  describe file(link_hexdump) do
    # HeaderSize
    its(:content) { should match /4C 00 00 00/ }
    # LinkCLSID
    its(:content) { should match /01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46/ }
  end
  describe command(<<-END_COMMAND
$link_basename = '#{link_basename}'
[byte[]] $bytes = get-content -encoding byte -path "$env:USERPROFILE\\Desktop\\${link_basename}.lnk" -totalcount 20
  foreach ( $byte in $bytes ) {
    $output += '{0:X2} ' -f $byte
  }
write-output $output 
END_COMMAND
) do
    # HeaderSize
    its(:stdout) { should match /4C 00 00 00/ }
    # LinkCLSID
    its(:stdout) { should match /01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46/ }
  end
end
