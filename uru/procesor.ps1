<#
    .SYNOPSIS
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

   .DESCRIPTION
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

    .EXAMPLE
    processor.ps1 -report 'report_.json' -directory 'reports' -warnings

    .PARAMETER warnings
    switch: specify to print examples with the status 'pending'. By default only the examples with the status 'failed' are printed.
#> 
param(
  [Parameter(Mandatory=$false)]
  [string]$report = 'report_.json',
  [Parameter(Mandatory=$false)]
  [string]$directory = 'reports',
  [int]$maxcount = 0,
  [switch]$warnings

)


$statuses = @('passed')

if ( -not ([bool]$PSBoundParameters['warnings'].IsPresent )) { 
  $statuses += 'pending'
}

$statuses_regexp = '(?:' + ( $statuses -join '|' ) +')'

$report_path = "${directory}/${report}";

if ($host.Version.Major -gt 2) {
  $report_obj = Get-Content -Path $report_path | ConvertFrom-Json;
  $count = 0
  foreach ($example in $report_obj.'examples') {
    if ( -not ( $example.'status' -match $statuses_regexp )) {
      Write-Output ("Test : {0}`r`nStatus: {1}" -f ($example.'full_description'),($example.'status'))
      $count++;
      if (($maxcount -ne 0) -and ($maxcount -lt $count)) {
        break
      }
    }
  }
  Write-Output ($report_obj.'summary_line');
} else {
  $report_body = Get-Content -Path $report_path;
  $report_body = $report_body -replace '.+\"summary_line\"','serverspec result: ';
  Write-Output $report_body;
}
