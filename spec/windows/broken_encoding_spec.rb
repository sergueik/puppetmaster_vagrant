require_relative '../windows_spec_helper'
# origin http://poshcode.org/3252
context 'Discover ASCII Files Corrupt with Unicode Fragments' do
	before(:each) do
		file_path = 'C:\Users\vagrant\ascii.txt'
		Specinfra::Runner::run_command(<<-END_COMMAND
			$content = @"
this is a test this is a test this is a test this is a test this is a test
"@
			write-output $content | out-file '#{file_path}' -encoding ascii
		END_COMMAND
		)

		file_path = 'C:\Users\vagrant\unicode.txt'
		Specinfra::Runner::run_command(<<-END_COMMAND
			$content = @"
this is a test this is a test this is a test this is a test this is a test
"@
			write-output $content | out-file '#{file_path}' -encoding Unicode
		END_COMMAND
		)

		file_path = 'C:\Users\vagrant\mixed.txt'
		Specinfra::Runner::run_command(<<-END_COMMAND
			$content = @"
this is a test this is a test this is a test this is a test this is a test
"@
			write-output $content | out-file '#{file_path}' -encoding Ascii
			write-output $content | out-file '#{file_path}' -append
			write-output $content | out-file '#{file_path}' -encoding Ascii -

append
		END_COMMAND
		)
	end
	{
		'ascii.txt' => 'US-ASCII',
		'unicode.txt'=> 'Unicode',
		'mixed.txt' => 'Unicode'
	}.each do |filename, encoding|
	describe command(<<-EOF
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

      [System.IO.FileStream]$content = New-Object System.IO.FileStream ($file_path,

[System.IO.FileMode]::Open)
      [byte[]]$byte_content = (New-Object System.IO.BinaryReader ($content)).ReadBytes

([convert]::ToInt32($content.Length))
      $content.Close()
      $offset = 0
      for ([int]$cnt = 0; $cnt -ne $byte_content.Length; $cnt++) { if ($byte_content[$cnt]

-eq 0) {
          if ($offset -eq 0) {
            $offset = $cnt + 1
          } } }


      $byte_count = $byte_content.Length - $offset
      if ($byte_count -gt $byte_content_size) {
        $byte_count = $byte_content_size
      }
      [bool]$high_ascii_byte_present= $false

      $zero_byte_count = 0
      for ($i = 0; $i -lt $byte_count; $i += 2) {
        if ($byte_content[$i + $offset] -eq 0) { $zero_byte_count++ }
        if ($byte_content[$i + $offset] -gt 127) { $high_ascii_byte_present= $true }
      }
      if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
        # big-endian Unicode
        return (New-Object System.Text.UnicodeEncoding $true,$false)
      }
      $zero_byte_count = 0
      for ($i = 1; $i -lt $byte_count; $i += 2) {
        if ($byte_content[$i + $offset] -eq 0) { $zero_byte_count++ }
        if ($byte_content[$i + $offset] -gt 127) { $high_ascii_byte_present= $true }
      }
      if (($zero_byte_count / ($byte_count / 2)) -ge $unicode_threshold) {
        # little-endian Unicode
        return (New-Object System.Text.UnicodeEncoding $false,$false)

      }

      #	UTF8
      if ($high_ascii_byte_present-eq $true) {
        return (New-Object System.Text.UTF8Encoding $false)
      } else {
        # ASCII
        return [System.Text.Encoding]::'ASCII'
      }
    }

    $result = test_bomless_file -file_path 'C:\\Users\\vagrant\\#{filename}'
    write-output $result.EncodingName
	EOF
	) do
			its(:exit_status) { should eq 0 }
			its(:stdout) { should contain encoding }
		end
	end
end