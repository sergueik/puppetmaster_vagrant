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
      # get few non-blank lines of the description
      # e.g. when the failed test is an inline command w/o a wrapping context 
      $full_description = $example.'full_description'
      if ($full_description -match '\n' ){
        $short_Description = ( $full_description -split '\n' | where-object { $_ -notlike '\s*' } |select-object -first 3 ) -join ' '
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
  # stats
  $stats = @{}
  foreach ($example in $report_obj.'examples') {
    $file_path = $example.'file_path'
    if (-not $stats.ContainsKey($file_path)) {
      $stats.Add($file_path,@{ 'passed' = 0; 'failed' = 0; 'pending' = 0; })
    }
    $stats[$file_path][$example.'status']++
  }

  $stats.Keys | ForEach-Object {
    $file_path = $_
    $data = $stats[$file_path]
    $total = $data['passed'] + $data['pending'] + $data['failed']
    Write-Output ('{0} {1}%' -f $file_path,(([math]::round(100 * $data['passed'] / $total,1))))
  }
  Write-Output ($resultobj.'summary_line')
} else {
  $resultbody = Get-Content -Path $resultpath
  $resultbody = $resultbody -replace '.+\"summary_line\"' , 'serverspec result: '
  Write-Output $resultbody
}
