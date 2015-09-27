# iterate over installed producs 
function read_registry {
  param(
    [string]$registry_hive = 'HKLM',
    [string]$registry_path,
    [string]$package_name,
    [string]$subfolder = '',
    [bool]$debug = $false

  )

  $install_location_result = $null
  switch ($registry_hive) {
    'HKLM' {
      pushd HKLM:
    }

    'HKCU' {
      pushd HKCU:
    }

    default: {
      throw ('Unrecognized registry hive: {0}' -f $registry_hive)
    }
  }

  cd $registry_path
  $apps = Get-ChildItem -Path .
  $apps | ForEach-Object {
    $registry_key = $_
    pushd $registry_key.Path
    $values = $registry_key.GetValueNames()

    if (-not ($values.GetType().BaseType.Name -match 'Array')) {
      throw 'Unexpected result type'
    }


    $values | Where-Object { $_ -match '^DisplayName$' } | ForEach-Object {

      try {
        $displayname_result = $registry_key.GetValue($_).ToString()

      } catch [exception]{
        Write-Debug $_
      }


      if ($displayname_result -ne $null -and $displayname_result -match "\\b${package_name}\\b") {
        $values2 = $registry_key.GetValueNames()
        $install_location_result = $null
        $values2 | Where-Object { $_ -match '\\bInstallLocation\\b' } | ForEach-Object {
          $install_location_result = $registry_key.GetValue($_).ToString()
          Write-Debug (($displayname_result,$registry_key.Name,$install_location_result) -join "`r`n")
        }
      }
    }
    popd
  }
  popd
  if ($subfolder -ne '') {
    return ('{0}{1}' -f $install_location_result,$subfolder)
  } else {
    return $install_location_result
  }
}

# Main script
$package_name = 'Puppet'
# Finging install info for application
if (-not [environment]::Is64BitProcess) {
   $registry_path  = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall'
} else {
   $registry_path = '/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall'
}
$Debugpreference = 'Continue'
$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
<# 
# NOTE: chocolatey natively detects that puppet is installed 
# and does it faster then this home-brewed script
# optional - discover if puppet is already installed, through Powershell
$install_path = read_registry -subfolder 'bin' -registry_path $registry_path -package_name $package_name -Debug $true
if ($install_path -ne $null -and $install_path -ne '' -and (test-path -path $install_path)) { 
  write-output ('{0} is already installed to {1}' -f $package_name, $install_path )
  exit
}
#>
& cinst.exe --yes puppet
