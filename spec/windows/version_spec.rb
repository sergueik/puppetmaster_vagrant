require_relative '../windows_spec_helper'

context 'Version check' do
  # uses fixed version of specinfra backend command
  # https://github.com/sergueik/specinfra/blob/master/lib/specinfra/backend/powershell/support/find_installed_application.ps1
  context 'Installed Application' do
    {
     'Java 8 Update 101' => '8.0.1010.13',
    }.each do |appName, appVersion|
    describe command(<<-EOF
      function FindInstalledApplication {
        param(
          [string]$appName,
          [string]$appVersion
        )
        $DebugPreference = 'Continue'
        Write-Debug ('appName  = "{0}", appVersion={1}' -f $appName,$appVersion)
        # fix to allow special character in the application names like 'Foo [Bar]'
        $appNameRegex = New-Object Regex (($appName -replace '\\[','\\[' -replace '\\]','\\]'))

        if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notmatch '64')
        {
          $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
          $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
        }
        else
        {
          $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*','HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
          $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
          $possible_path = 'HKCU:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
          if (Test-Path $possible_path)
          {
            $keys += (Get-ItemProperty $possible_path)
          }
        }

        if ($appVersion -eq $null) {
          $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) })
          Write-Debug ('applications found:' + $result)
          Write-Output ([boolean]($result.Length -gt 0))
        }
        else {
          $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) } | Where-Object { $_.DisplayVersion -eq $appVersion })
          Write-Debug ('applications found:' + $result)
          Write-Output ([boolean]($result.Length -gt 0))
        }
      }

      $exitCode = 1
      $ProgressPreference = 'SilentlyContinue'
      try {
        $success = ((FindInstalledApplication -appName '#{appName}' -appVersion '#{appVersion}') -eq $true)
        if ($success -is [boolean] -and $success) {
          $exitCode = 0 }
      } catch {
        Write-Output $_.Exception.Message
      }
      Write-Output "Exiting with code: ${exitCode}"
    EOF
    ) do
        its(:stdout) do
          should match /Exiting with code: 0/
        end
      end
    end
  end
end

