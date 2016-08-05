param(
  [string]$report = 'report_.json',
  [string]$directory = 'reports',
  [int]$maxcount = 0,
  [switch]$warnings

)

$report_path = "${directory}/${report}";

if ($host.Version.Major -gt 2) {
  $report_obj = Get-Content -Path $report_path | ConvertFrom-Json;
  $count = 0
  foreach ($example in $report_obj.'examples') {
    if (-not ($example.'status' -match 'passed')) {
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
