$rawdata = @'
red
128
   green
64
 blue   
      192 
black
  0
  white
255
'@
$collect_keys = @(
  'red',
  'blue'
)
write-host ("Raw Data:`n--`n{0}`n--`n" -f $rawdata)
$results = @{}
$lines = $rawdata -split "`r?`n"
$line_count = $lines.Count
0..($line_count-1) |foreach-object {
  $index = $_
  $text = $lines[$index] 
  [String]$key = [String](
    [Array]::Find( $collect_keys,
      [Predicate[String]]{
        if ($text -match $args[0] ) { return $args[0] } else { return $null}
    })
  )
  if (($key -ne '') -and ($key -ne $null)) { 
    $results[$key] = [Convert]::ToDouble($lines[$index+1].trim()) 
  }
}

$result_json =  (convertTo-json -inputobject $results) -join "`n"
write-host ("Result:`n--`n{0}`n--`n" -f $result_json)
<#
try {
  write-host ("Result:`n--`n{0}`n--`n" -f $result_json) -erroraction silentlycontinue
} catch [Microsoft.PowerShell.Commands.WriteErrorException] {
  # will be thrown
  # see also:
  # https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.writeerrorexception
}
#>
