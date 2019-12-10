# inspired by # http://www.cyberforum.ru/powershell/thread2549860.html

# setup:
# cmd %%-
# for /L %_ in (1 1 10) do @copy NUL (%_).mpg
<#
    Directory: C:\Users\sergueik\files
Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---         12/9/2019  12:52 PM          0 (1).mpg
-a---         12/9/2019  12:52 PM          0 (10).mpg
-a---         12/9/2019  12:52 PM          0 (2).mpg
-a---         12/9/2019  12:52 PM          0 (3).mpg
-a---         12/9/2019  12:52 PM          0 (4).mpg
-a---         12/9/2019  12:52 PM          0 (5).mpg
-a---         12/9/2019  12:52 PM          0 (6).mpg
-a---         12/9/2019  12:52 PM          0 (7).mpg
-a---         12/9/2019  12:52 PM          0 (8).mpg
-a---         12/9/2019  12:52 PM          0 (9).mpg

#>
$to_left_padded_number_string = { $name = $_; $number = $name -replace '\(|\)|\.mpg', '' ; ( '{0:0000}' -f (0 + $number )) }
get-childitem -path '.' | select-object -expandproperty Name | sort-object $to_left_padded_number_string

# alternative from
# https://stackoverflow.com/questions/18209617/print-out-files-in-a-directory-sorted-by-filename
$to_left_padded_number_in_name = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
get-childitem -path '.' | select-object -expandproperty Name | sort-object $to_left_padded_number_in_name
<#

(1).mpg
(2).mpg
(3).mpg
(4).mpg
(5).mpg
(6).mpg
(7).mpg
(8).mpg
(9).mpg
(10).mpg

#>

# alternative
$to_number_modulo = { $name = $_; $number = $name -replace '\(|\)|\.mpg', '' ; 1000 + $number }
get-childitem -path '.' | select-object -expandproperty Name | sort-object $to_number_modulo
<#

(1).mpg
(2).mpg
(3).mpg
(4).mpg
(5).mpg
(6).mpg
(7).mpg
(8).mpg
(9).mpg
(10).mpg

#>

# NOTE: passing parameters the following "code block" way does not work
$to_number_code_block = { param($name); $number = $name -replace '\(|\)|\.mpg', '' ; 1000 + $number  }
get-childitem -path '.' | select-object -expandproperty Name | sort-object $to_number_code_block
<#
order of the result is unspecified
#>


# alternative
$to_number_from_name = { $name = $_.Name; $number = $name -replace '\(|\)|\.mpg', '' ; 1000 + $number }
get-childitem -path '.' | sort-object $to_number_from_name


# brute force
# string key ( numberic key, is similar)
$files = @{}; get-childitem -path '.' | foreach-object { $number = $_.Name -replace '\(|\)|\.mpg', '' ; $files[( '{0:0000}' -f (0 + $number ))] = $_.Name }
$files.keys | sort-object | foreach-object { write-output $files[$_]}

# alternative from http://www.cyberforum.ru/powershell/thread2549860.html
get-childitem -path '.'| sort {[Int32]($_.Basename -replace '\(|\)')}

# NOTE:  it appears impossible to ask Explorer application to do the desired sorting
# $o = new-object -com Shell.Application
# $folder =  $o.Namespace($dir_path)
# $folder.Items()|  foreach-object { write-output $_.Name }

