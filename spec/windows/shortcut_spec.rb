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

# origin: http://powershell.com/cs/media/p/45855.aspx
context 'Shortcuts' do
  link_basename = 'puppet_test'

  describe command(<<-END_COMMAND
$link_basename = '#{link_basename}'
[String]$Shortcut = "$env:USERPROFILE\\Desktop\\${link_basename}.lnk"
$CLSID = '00021401-0000-0000-C000-000000000046' 
try { 
  $filestream = [IO.File]::OpenRead($Shortcut) 
  $binary_reader = New-Object IO.BinaryReader($filestream) 
  $sz = $binary_reader.ReadUInt32() # SHELL_LINK_HEADER size 
  $filestream.Position = 0 
  $buf = New-Object "Byte[]" $sz 
  [void]$binary_reader.Read($buf, 0, $buf.Length) 
   
  $status = [bool](([Byte[]]$buf[4..19] -as [Guid]).Guid.ToUpper().Equals($CLSID))  

  $binary_reader.Dispose()
} catch [Exception] { 
  $status = $false
}

$exit_code  = [int](-not $status )
write-output "status = ${status}"
write-output "exiting with ${exit_code}"
exit $exit_code


END_COMMAND
) do
      its(:stdout) { should match /true/i }
        its(:stdout) { should match /exiting with 0/i }
        # avoid sporadically collecting the <AV>Preparing modules for first use.</AV> error
        its(:exit_status) {should eq 0} 
  end
end 
