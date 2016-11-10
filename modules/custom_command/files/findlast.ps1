# setting the mockup environment
$statedir = $env:TEMP

$last_run_report = 'last_run_report.yaml'
$filename_mask = ('{0}.*' -f $last_run_report)
pushd $statedir
Write-Host ('Mocking {0} {1}' -f $last_run_report,"${root_path}\${last_run_report}")
Write-Output '' | Out-File -FilePath "${statedir}\${last_run_report}"
popd

# Log rotation code

if (Test-Path -Path $statedir) {
  pushd $statedir
  if (Test-Path -Path $last_run_report) {
    $file_count = @( Get-ChildItem -Name "${last_run_report}.*" -ErrorAction 'Stop').count
    [console]::Error.WriteLine(('Copy ' + $last_run_report + ' ' + "${last_run_report}.$($file_count+1)"))
    Copy-Item $last_run_report -Destination "${last_run_report}.$($file_count+1)" -Force
  }
  popd
}
