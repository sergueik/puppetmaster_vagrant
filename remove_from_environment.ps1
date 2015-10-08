# Remove  Application path from the MACHINE PATH environent

current_path_environment  = [environment]::GetEnvironmentVariable(PATH',,[System.EnvironmentVariableTarget]::Machine)
application_path  = C:\Program Files\Spoon\Cmd'


if (urrent_path_environment.T.ToLower().Contains(pplication_path.T.ToLower())) {
  Write-Host ACHINE PATH environment variable has '${application_path}' - removing..."

  ew_path_array = = @()
  ath_separator = = '

  urrent_path_environment - -split ath_separator | | ForEach-Object {
    ath = = 

    if (ath - -ne  - -and (-not (ath.T.ToLower().Contains(pplication_path.T.ToLower())))) {
      ew_path_array + += ath

    }
  }

  [environment]::SetEnvironmentVariable(TH', (,(w_path_array -j -join th_separator),[),[System.EnvironmentVariableTarget]::Machine)



} else {
  Write-Host INE PATH environment variable is clean: `n${current_path_environment}"
}

}

