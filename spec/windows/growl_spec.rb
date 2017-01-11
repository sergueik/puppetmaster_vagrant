require_relative '../windows_spec_helper'
context 'Growl' do
	# origin http://poshcode.org/?show=1276
	describe command(<<-EOF
		$appPath = Get-ItemProperty -Path 'HKCU:\\Software\\Growl' -Name '(default)' | Select-Object -ExpandProperty '(default)'
		[Reflection.Assembly]::LoadFrom([System.IO.Path]::Combine((Split-Path -Path $appPath -Parent),'Growl.Connector.dll')) | Out-Null

		$appName = 'Test'

		$PowerGrowlerNotices = @{}

		$PowerGrowler = New-Object 'Growl.Connector.GrowlConnector'

		function Register-GrowlType {
			param(
				[string]$AppName,
				[string]$Name,
				[Parameter(Mandatory = $false)]
				[string]$Icon = $null,
				[string]$DisplayName = $Name,
				[Parameter(Mandatory = $false)]
				[string]$AppIcon
			)

			[Growl.Connector.NotificationType]$Notice = New-Object Growl.Connector.NotificationType ($Name,$true)
			$Notice.DisplayName = $DisplayName
			if ($icon) {
				$Notice.Icon = Convert-Path (Resolve-Path $Icon)
			}
			if (-not $PowerGrowlerNotices.Contains($AppName)) {
				$PowerGrowlerNotices.Add($AppName,(New-Object Growl.Connector.Application ($AppName)))

				$PowerGrowlerNotices.$AppName = Add-Member -input $PowerGrowlerNotices.$AppName -Name Notices -Type NoteProperty -Value (New-Object hashtable) -PassThru
				$PowerGrowlerNotices.$AppName.Icon = Convert-Path (Resolve-Path $AppIcon)
			}
			if ($PowerGrowlerNotices.$AppName.Notices.ContainsKey($Name)) {
				$PowerGrowlerNotices.$AppName.Notices.Add($Name,$Notice)
			}
			$PowerGrowler.Register($PowerGrowlerNotices.$AppName,[Growl.Connector.NotificationType[]]@( $PowerGrowlerNotices.$AppName.Notices.Values))
		}

		function Send-Growl {
			[CmdletBinding(DefaultParameterSetName = 'DataCallback')]
			param(
				[ValidateScript({ $PowerGrowlerNotices.Contains($AppName) })]
				[string]$AppName,
				[ValidateScript({ $PowerGrowlerNotices.$AppName.Notices.ContainsKey($_) })]
				[string]$NoticeType = 'Default',
				[string]$Caption,
				[string]$Message,
				[string]$Icon,
				[Growl.Connector.Priority]$Priority = 'Normal'
			)

			$notice = New-Object Growl.Connector.Notification $appName,$NoticeType,(Get-Date).Ticks.ToString(),$caption,$Message

			if ($Icon) { $notice.Icon = Convert-Path (Resolve-Path $Icon) }
			if ($Priority) { $notice.Priority = $Priority }

			if ($DebugPreference -gt 'SilentlyContinue') { Write-Output $notice }
			$PowerGrowler.Notify($notice)
		}

		$DefaultNoticeType = 'Default'
		Register-GrowlType -AppName $AppName -Name $DefaultNoticeType #	-AppIcon "c:\\uru\\sample.ico"
		Send-Growl -AppName $AppName -Caption 'Ruby Notification' -Message 'This is a test'
		write-output 'status'
		EOF
		) do
    its(:stdout) { should contain 'status' }
	end
end

