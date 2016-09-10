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

$file_path = ("${directory}/${name}" -replace '/' , '\');
if (-not (Test-Path $file_path)) {
  write-output ('Results is unavailable: "{0}"' -f $file_path )
  exit 0
}
if ($host.Version.Major -gt 2) {
  $result_obj = Get-Content -Path $file_path | ConvertFrom-Json ;
  $count = 0
  foreach ($example in $result_obj.'examples') {
    if ( -not ( $example.'status' -match $statuses_regexp )) {
      # get few non-blank lines of the description
      # e.g. when the failed test is an inline command w/o a wrapping context
      $full_description = $example.'full_description'
      if ($full_description -match '\n|\\n' ){
        $short_Description = ( $full_description -split '\n|\\n' | where-object { $_ -notlike '\s*' } |select-object -first 3 ) -join ' '
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
  foreach ($example in $result_obj.'examples') {
    $file_path = $example.'file_path'
    if (-not $stats.ContainsKey($file_path)) {
      $stats.Add($file_path, (New-Object -TypeName PSObject -Property $props ))
    }
    # Unable to index into an object of type System.Management.Automation.PSObject
    $stats[$file_path].$($example.'status') ++

  }
  write-output 'Stats:'
  $stats.Keys | ForEach-Object {
    $file_path = $_
    $data = $stats[$file_path]
    $total = $data.Passed + $data.Pending + $data.Failed
    Write-Output ('{0} {1} %' -f $file_path,(([math]::round(100 * $data.Passed / $total,1))))
  }
  write-output 'Summary:'
  Write-Output ($result_obj.'summary_line')
} else {
  Write-Output ((Get-Content -Path $file_path) -replace '.+\"summary_line\"' , 'serverspec result: ')
}
