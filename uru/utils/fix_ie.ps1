# Suppress the Internet Explorer confirmation 
# 'allow active content to run in files on my computer'
function change_registry_setting {

  param(
    [string]$hive,
    [string]$path,
    [string]$name,
    [string]$value,
    [string]$propertyType,
    [switch]$debug
  )

  pushd $hive
  cd '\'
  cd $path
  $local:setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
  if ($local:setting -ne $null) {
    if ([bool]$PSBoundParameters['debug'].IsPresent) {
      Select-Object -ExpandProperty $name -InputObject $local:setting
    }
    if ($local:setting -ne $value) {
      Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
    }
  } else {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType $propertyType
  }
  popd

}

$hive = 'HKCU:'
$path = 'Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'
# NOTE: the 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections', 'SavedLegacySettings'
# registry value not currently applied

change_registry_setting -hive $hive -Path $path -Name $name -Value $value -PropertyType $propertyType
