<#
    .SYNOPSIS
    This subroutine processes the serverspec report and prints full description of failed examples.
    Optionally shows pending examples, too.

   .DESCRIPTION
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

    .EXAMPLE
    processor.ps1 -report 'result.json' -directory 'reports'  -serverspec 'spec/local' -warnings -maxcount 10

    .PARAMETER warnings
    switch: specify to print examples with the status 'pending'. By default only the examples with the status 'failed' are printed.
#>
param(
  [Parameter(Mandatory = $false)]
  [string]$name = 'result.json',
  [Parameter(Mandatory = $false)]
  [string]$directory = 'results',
  [Parameter(Mandatory = $false)]
  [string]$serverspec = 'spec\local',
  [int]$maxcount = 100,
  [switch]$warnings
)

$statuses = @('passed')

if ( -not ([bool]$PSBoundParameters['warnings'].IsPresent )) {
  $statuses += 'pending'
}

$statuses_regexp = '(?:' + ( $statuses -join '|' ) +')'

$results_path = ("${directory}/${name}" -replace '/' , '\');
if (-not (Test-Path $results_path)) {
  write-output ('Results is unavailable: "{0}"' -f $results_path )
  exit 0
}
if ($host.Version.Major -gt 2) {
  $results_obj = Get-Content -Path $results_path | ConvertFrom-Json ;
  $count = 0
  foreach ($example in $results_obj.'examples') {
    if ( -not ( $example.'status' -match $statuses_regexp )) {
      # get few non-blank lines of the description
      # e.g. when the failed test is an inline command w/o a wrapping context
      $full_description = $example.'full_description'
      if ($full_description -match '\n|\\n' ){
        $short_Description = ( $full_description -split '\n|\\n' | where-object { $_ -notlike '\s*' } |select-object -first 2 ) -join ' '
      } else {
        $short_Description = $full_description
      }
      Write-Output ("Test : {0}`r`nStatus: {1}" -f $short_Description,($example.'status'))
      $count++;
      if (($maxcount -ne 0) -and ($maxcount -lt $count)) {
        break
      }
    }
  }
  # compute stats -
  # NOTE: there is no outer context information in the `result.json`
  $stats = @{}
  $props =  @{
    Passed = 0
    Failed = 0
    Pending = 0
  }
  foreach ($example in $results_obj.'examples') {
    $spec_path = $example.'file_path'
    if (-not $stats.ContainsKey($spec_path)) {
      $stats.Add($spec_path, (New-Object -TypeName PSObject -Property $props ))
    }
    # Unable to index into an object of type System.Management.Automation.PSObject
    $stats[$spec_path].$($example.'status') ++

  }

  write-output 'Stats:'
  $stats.Keys | ForEach-Object {
    $spec_path = $_
    # extract outermost context from spec:
    $context_line = select-string -pattern @"
context ['"].+['"] do
"@ -path $spec_path | select-object -first 1
    $context = $context_line -replace @"
^.+context\s+['"]([^"']+)['"]\s+do\s*$
"@, '$1'
    # NOTE: single quotes needed in the replacement
    $number_examples = $stats[$spec_path]
    # not counting pending examples 
    # $total_number_examples = $number_examples.Passed + $number_examples.Pending + $number_examples.Failed
    $total_number_examples = $number_examples.Passed + $number_examples.Failed
    Write-Output ("{0}`t{1}%`t{2}" -f ( $spec_path -replace '^.+[\\/]','' ),([math]::round(100.00 * $number_examples.Passed / $total_number_examples,2)), $context)
  }
  write-output 'Summary:'
  Write-Output ($results_obj.'summary_line')
} else {
  Write-Output (((Get-Content -Path $results_path) -replace '.+\"summary_line\"' , 'serverspec result: ' ) -replace '}', '' )
}
