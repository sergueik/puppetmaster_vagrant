# setting the mockup environment

$statedir = $env:TEMP

$last_run_report = 'last_run_report.yaml'
$filename_mask = ('{0}.*' -f $last_run_report)
pushd $statedir
Write-Host ('Mocking {0} {1}' -f $last_run_report,"${root_path}\${last_run_report}")
Write-Output '' | Out-File -FilePath "${statedir}\${last_run_report}"
popd


# log file rotation code

if (Test-Path -Path $statedir) {

  pushd $statedir


  if (Test-Path -Path $last_run_report) {

    $file_count = @( Get-ChildItem -Name "${last_run_report}.*" -ErrorAction 'Stop').count

    if ($file_count -gt 0) {
      $file_count..1 | ForEach-Object {
        $cnt = $_
        [console]::Error.WriteLine(("Move ${last_run_report}.{0} ${last_run_report}.{1}" -f $cnt,($cnt + 1)))
        Move-Item "${last_run_report}.${cnt}" -Destination "${last_run_report}.$(($cnt+1))" -Force
      }
    }
    [console]::Error.WriteLine(('Move ' + $last_run_report + ' ' + "${last_run_report}.1"))
    Move-Item $last_run_report -Destination "${last_run_report}.1" -Force
  }
  popd
}
