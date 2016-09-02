<#
    .SYNOPSIS
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

   .DESCRIPTION
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

    .EXAMPLE
    processor.ps1 -report 'result.json' -directory 'reports' -warnings

    .PARAMETER warnings
    switch: specify to print examples with the status 'pending'. By default only the examples with the status 'failed' are printed.
#> 
param(
  [Parameter(Mandatory = $false)]
  [string]$report = 'result.json',
  [Parameter(Mandatory = $false)]
  [string]$directory = 'results',
  [Parameter(Mandatory = $false)]
  [string]$serverspec = 'spec\local',
  [int]$maxcount = 0,
  [switch]$warnings

)


$statuses = @('passed')

if ( -not ([bool]$PSBoundParameters['warnings'].IsPresent )) { 
  $statuses += 'pending'
}

$statuses_regexp = '(?:' + ( $statuses -join '|' ) +')'

$resultpath = "${directory}/${report}";

if ($host.Version.Major -gt 2) {
  $resultobj = Get-Content -Path $resultpath | ConvertFrom-Json;
  $count = 0
  foreach ($example in $resultobj.'examples') {
    if ( -not ( $example.'status' -match $statuses_regexp )) {
      Write-Output ("Test : {0}`r`nStatus: {1}" -f ($example.'full_description'),($example.'status'))
      $count++;
      if (($maxcount -ne 0) -and ($maxcount -lt $count)) {
        break
      }
    }
  }
  Write-Output ($resultobj.'summary_line')
} else {
  $resultbody = Get-Content -Path $resultpath
  $resultbody = $resultbody -replace '.+\"summary_line\"' , 'serverspec result: '
  Write-Output $resultbody
}
