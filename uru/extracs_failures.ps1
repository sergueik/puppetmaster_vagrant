param (
[string]$report = 'report_.json' 
)
$reports_root = '.'
$report = "${reports_root}/${report}"; 
if  ($host.Version.Major -gt 2) {
  $report_obj = get-content -path $report | convertfrom-json; 
  foreach ($example in $report_obj.'examples') { 
    if ( -not  ($example.'status' -match 'passed' ) ) {
      write-output ("Test : {0}`r`nStatus: {1}" -f ($example.'full_description' ), ($example.'status') )
    }
  } 
  write-output ($report_obj.'summary_line');
} else { 
  $report_body = get-content -path $report ; 
  $report_body = $report_body -replace '.+\"summary_line\"', 'serverspec result: '; 
  write-output $report_body;   
}
