# https://www.compart.com/en/unicode/U+043F
$filename1 = ([String]::join('',[String]::join('', @([char]0x043f,[char]0x0440,[char]0x0438,[char]0x0432,[char]0x0435,[char]0x0442)),'.txt'))
# https://docs.microsoft.com/en-us/dotnet/api/system.text.encoding.convert?view=netframework-4.0

$bytes1 = [System.Text.Encoding]::Unicode.GetBytes($filename1)
$bytes2 = [System.Text.Encoding]::Convert([System.Text.Encoding]::Unicode, [System.Text.Encoding]::UTF8, $bytes1 )
$filename2 = [System.Text.Encoding]::UTF8.GetString($bytes2)
# $bytes1 and $bytes2 are different - but filenames are the same
$filename2 -eq $filename1
True

new-item -path $filename1

# the filename will look right in the VM
