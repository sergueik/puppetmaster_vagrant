
# origin: http://stackoverflow.com/questions/2093680/changing-cmd-window-properties-programmatically
# alternative: 
# https://msdn.microsoft.com/en-us/library/ms686033%28VS.85%29.aspx
# https://msdn.microsoft.com/en-us/library/windows/desktop/ms682087%28v=vs.85%29.aspx

$root_path = 'HKCU:\Console'
$data = @{
  'ScreenBufferSize' = 0x270f0050;
  'FontSize' = 0x120000; 
  # 14pt 0xe0000 
  # 16pt 0x100000,
  # 18pt 0x120000,
  # 20pt 0x140000
  # 24pt 0x180000
  'FontFamily' = 0x36;
  'FontWeight' = 0x190;
  'QuickEdit' = 0x1;
}

@(
  '%SystemRoot%_System32_cmd.exe',
  '%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe',
  'C:_Program Files (x86)_Midnight Commander_mc.exe',
  '%SystemRoot%_SysWOW64_cmd.exe',
  '%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe'
) | ForEach-Object {
  $console_application_path = $_
  $pathCreate = $root_path + '\' + $console_application_path
  if (-not (Test-Path $pathCreate)) {
    New-Item -Path $pathCreate
  }
  New-ItemProperty -Path $pathCreate -Name 'FaceName' -Value 'Lucida Console' -Force | Out-Null
  $data.Keys | ForEach-Object { $key = $_; $value = $data[$key]
    New-ItemProperty -Path $pathCreate -Name $key -Value $value -PropertyType 'DWORD' -Force | Out-Null
  }
}

