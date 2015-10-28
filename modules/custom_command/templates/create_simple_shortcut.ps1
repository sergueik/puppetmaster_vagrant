$shortcut_basename = '<%=@shortcut_basename -%>'
$shortcut_pathname = "<%=@shortcut_pathname -%>"
if (-not $shortcut_pathname) {
  $shortcut_pathname = "$Home\Desktop"
}
$shortcut_path = ('{0}\{1}.lnk', $shortcut_pathname, $shortcut_basename  )
$shortcut_targetpath = '<%=@shortcut_targetpath -%>'
$shortcut_target_arguments = '<%=@shortcut_target_arguments -%>'
$o = new-object -ComObject 'WScript.Shell'
$s = $o.CreateShortcut($shortcut_path)
$s.TargetPath = $shortcut_targetpath 
$s.Arguments = $shortcut_target_arguments
$s.Save()

