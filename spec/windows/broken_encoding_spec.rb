require_relative '../windows_spec_helper'

context 'Command' do
  # create a mix content file
  # to setup a test case
  file_path = 'C:\Users\sergueik\c.groovy'
  describe command(<<-EOF
# origin http://poshcode.org/3252
function test_bomless_file {
  param(
    $file_path = '',
    [int]$byte_content_size = 512,
    [decimal]$unicode_threshold = .5
  )
  if (-not (Test-Path -Path $file_path)) {
    Write-Error -Message "Cannot read: ${file_path}"
    return
  }

  # http://stackoverflow.com/questions/2980182/binary-file-to-string
  # $byte_content = (Get-Content -Path $file_path -Encoding byte -ReadCount $byte_content_size -TotalCount $byte_content_size)
  # $byte_count = $byte_content.Count


  [System.IO.FileStream]$content = New-Object System.IO.FileStream ($file_path,[System.IO.FileMode]::Open)
  #  Cannot find an overload for "FileStream" and the argument count:3
  # , [System.IO.FileAccess]::CanRead )
  [byte[]]$byte_content = (New-Object System.IO.BinaryReader ($content)).ReadBytes([convert]::ToInt32($content.Length))
  $content.Close()
  $offset = 0
  for ([int]$cnt = 0; $cnt -ne $byte_content.Length; $cnt++) { if ($byte_content[$cnt] -eq 0) {
      if ($offset -eq 0) {
        $offset = $cnt + 1
        Write-Output $cnt
      } } }


  $byte_count = $byte_content.Length - $offset
  if ($byte_count -gt $byte_content_size) {
    $byte_count = $byte_content_size
  }
  [bool]$high_ascii_byte_count = $false

  # check if big endian Unicode first - even-numbered index bytes will be 0)
  $zero_byte_count = 0
  for ($i = 0; $i -lt $byte_count; $i += 2) {
    if ($byte_content[$i + $offset] -eq 0) { $zero_byte_count++ }
    if ($byte_content[$i + $offset] -gt 127) { $high_ascii_byte_count = $true }
  }
  if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
    # big-endian Unicode with no BOM
    New-Object (System.Text.UnicodeEncoding $true,$false)
    return
  }
  # check if little endian Unicode next - odd-numbered index bytes will be 0)
  $zero_byte_count = 0
  for ($i = 1; $i -lt $byte_count; $i += 2) {
    if ($byte_content[$i + $offset] -eq 0) { $zero_byte_count++ }
    if ($byte_content[$i + $offset] -gt 127) { $high_ascii_byte_count = $true }
  }
  if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
    # little-endian Unicode with no BOM
    return (New-Object System.Text.UnicodeEncoding $false,$false)

  }

  #  UTF8 with no BOM
  if ($high_ascii_byte_count -eq $true) {
    return (New-Object System.Text.UTF8Encoding $false)
  } else {
    # if made it this far, I'm calling it ASCII; done deal pal  
    return [System.Text.Encoding]::'ASCII'
  }

}

$result = test_bomless_file -file_path '#{file_path}'
write-output $result.EncodingName

EOF
) do 
    its(:stdout) { should match /US-ASCII/i }
    its(:exit_status) { should eq 0 }
  end
end
