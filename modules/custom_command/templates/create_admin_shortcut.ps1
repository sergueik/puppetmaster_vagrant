$shortcut_basename = '<%=@shortcut_basename -%>'
$shortcut_pathname = "<%=@shortcut_pathname -%>"
if (-not $shortcut_pathname) {
  $shortcut_pathname = "$Home\Desktop"
}
$shortcut_path = ('{0}\{1}.lnk', $shortcut_pathname, $shortcut_basename  )
$shortcut_targetpath = '<%=@shortcut_targetpath -%>'
$shortcut_target_arguments = '<%=@shortcut_targe_arguments -%>'
$shortcut_run_as_admin = '<%=@shortcut_run_as_admin -%>' # pass 'true' argument as string
$o = new-object -ComObject 'WScript.Shell'
$s = $o.CreateShortcut($shortcut_path)
$s.TargetPath = $shortcut_targetpath 
$s.Arguments = $shortcut_target_arguments
$s.Save()
exit if ( -not ($shortcut_run_as_admin -match 'true'))
$bytes = [System.IO.File]::ReadAllBytes($shortcut_path) 
$bytes[0x15] = $bytes[0x15] -bor 0x20 # set byte 21 (0x15) bit 6 (0x20) ON
tem.IO.File]::WriteAllBytes( $shortcut_targetpath, $bytes)

