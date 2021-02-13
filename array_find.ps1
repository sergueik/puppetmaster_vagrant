# based on:
# https://stackoverflow.com/questions/21209946/array-find-on-powershell-array/21210062
# https://stackoverflow.com/questions/18877580/powershell-and-the-contains-operator

$expected = @(
  'Red',
  'Green',
  'Blue'
)

$actual = @'
green

'@
[String]$text = $actual
$exact_match_status = [Boolean](
  [Array]::Find( $expected,
    [Predicate[String]]{
      return ($args[0] -eq $text)
  })
)
write-output "Exact match status: ${exact_match_status}"
$contains_match_status = [Boolean](
  [Array]::Find( $expected,
    [Predicate[String]]{
      return ($text -match $args[0] )
  })
)

write-output ('Contains match status: {0}' -f  $contains_match_status)

