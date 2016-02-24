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

  $byte_content = (Get-Content -Path $file_path -Encoding byte -ReadCount $byte_content_size -TotalCount $byte_content_size)
  $byte_count = $byte_content.Count
  [bool]$high_ascii_byte_count = $false

  # big endian Unicode - even bytes will be 0
  $zero_byte_count = 0
  for ($i = 0; $i -lt $byte_count; $i += 2) {
    if ($byte_content[$i] -eq 0) { $zero_byte_count++ }
    if ($byte_content[$i] -gt 127) { $high_ascii_byte_count = $true }
  }
  if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
    # big-endian Unicode with no BOM
    New-Object (System.Text.UnicodeEncoding $true,$false)
    return
  }
  # little endian Unicode - odd bytes will be 0
  $zero_byte_count = 0
  for ($i = 1; $i -lt $byte_count; $i += 2) {
    if ($byte_content[$i] -eq 0) { $zero_byte_count++ }
    if ($byte_content[$i] -gt 127) { $high_ascii_byte_count = $true }
  }
  if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
    # little-endian Unicode with no BOM
    return (New-Object System.Text.UnicodeEncoding $false,$false)

  }

  #  UTF8 - too many 
  if ($high_ascii_byte_count -eq $true) {
    return (New-Object System.Text.UTF8Encoding $false)
  } else {
    # ASCII 
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
