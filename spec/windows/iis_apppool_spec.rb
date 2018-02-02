require_relative '../windows_spec_helper'
require 'spec_helper'

context 'IIS' do

context 'Basic' do
  describe command(<<-EOF
  Import-Module WebAdministration
  Get-ItemProperty -Path IIS:\\AppPools\\

  EOF

  ) do
      its (:stdout) { should contain /AppPools/}
    end
  end

  context 'IIS App Pools' do

    before(:all) do
      app_pool_name = 'my-test-app'
      app_pool_dotnet_version = 'v4.0'
      iis_app_name = 'my-test-app.test'
      directory_path = 'D:\SomeFolder'
      port = 8000
      Specinfra::Runner::run_command(<<-END_COMMAND

      # origin : http://geekswithblogs.net/QuandaryPhase/archive/2013/02/24/create-iis-app-pool-and-site-with-windows-powershell.aspx

      Import-Module WebAdministration

      $iisAppPoolName = '#{app_pool_name}'
      $iisAppPoolDotNetVersion = '#{app_pool_dotnet_version}'
      $iisAppName = '#{iis_app_name}'
      $directoryPath = '#{directory_path}'
      $port = #{port}

      mkdir $directoryPath
      # navigate to the app pools root
      pushd IIS:\\AppPools\\

      #check if the app pool exists
      if (!(Test-Path $iisAppPoolName -pathType container))
      {
          #create the app pool
          $appPool = New-Item $iisAppPoolName
          $appPool | Set-ItemProperty -Name 'managedRuntimeVersion' -Value $iisAppPoolDotNetVersion
      }
      popd

      # navigate to the sites root
      pushd IIS:\\Sites\\

      # check if the site exists
      if (Test-Path $iisAppName -pathType container)
      {
          return
      }
      # create the site
      $iisApp = New-Item $iisAppName -bindings @{protocol='http';bindingInformation=":${port}:" + $iisAppName} -physicalPath $directoryPath
      # create the app pool
      $iisApp | Set-ItemProperty -Name 'applicationPool' -Value $iisAppPoolName
      popd
      END_COMMAND
      )
    end

    describe command( <<-EOF
    [Xml]$raw_data = invoke-expression -command 'C:\\Windows\\system32\\inetsrv\\appcmd.exe list apppool /xml';

    $raw_data.SelectNodes("/appcmd//*[@state = 'Started']") | out-null

    $cnt  = 0
    $grid = @()


    $raw_data.SelectNodes("/appcmd//*[@state = 'Started']")|foreach-object {
      $name = $_.'APPPOOL.NAME';
      # skip pre-installed

      if ((-not ( $name -match 'DefaultAppPool' )) `
        -and  `
        (-not ($name -match '^.NET v4.5 Classic$')) `
        -and  `
        (-not ($name -match '^.NET v4.5$')) `
        -and  `
        (-not ($name -match '^.NET v2.0 Classic$')) `
        -and  `
        (-not ($name -match '^.NET v2.0$')) `
        -and  `
        (-not ($name -match '^Classic .NET AppPool$')) `
        -and  `
        (-not ($name -match '^ASP.NET v4.0 Classic$')) `
        -and  `
        (-not ($name -match '^ASP.NET v4.0$')) `
        ) {
        $row = New-Object PSObject
        $row | add-member Noteproperty Name            ('{0}' -f $name             )
        $row | add-member Noteproperty PipelineMode    ('{0}' -f $_.PipelineMode   )
        $row | add-member Noteproperty RuntimeVersion  ('{0}' -f $_.RuntimeVersion )
        $row | add-member Noteproperty Row             ('{0}' -f $cnt              )
        $cnt ++
        $grid  += $row
        $row = $null
      }
    }

    $grid | format-list

    EOF
    ) do
      its(:exit_status) {should eq 0 }
      expected_console_output = <<-EOF
        Name           : my-test-app
        PipelineMode   : Integrated
        RuntimeVersion : v4.0
        Row            : 0
      EOF
      expected_console_output.split(/\n/).each do |line|
        line.gsub!(/^\s+/,'').gsub!(/\s+$/,'')
        its(:stdout) {should  contain line}
      end
    end

    context 'IIS AppPools WMI' do
      # raw WMI methods in the case the WebAdministration Powershell module is failing to load
      # origin: http://forum.oszone.net/thread-332871.html
      # http://wutils.com/wmi/root/webadministration/applicationpool/#getstate_methods
      app_pool_name = 'DefaultAppPool'
      app_pool_name = '.NET v4.5 Classic'
      context 'Example 1' do
        describe command(<<-EOF
          $ApppoolName = '#{app_pool_name}'
          ((Get-WmiObject -Namespace root\\WebAdministration -Query "Select Name FROM ApplicationPool WHERE Name='${ApppoolName}'").GetState()).ReturnValue
        EOF
        ) do
        its(:stdout) { should match '1' }
        end
      end
      context 'Example 2' do
        describe command(<<-EOF
          $ApppoolName = '#{app_pool_name}'
          $o = Get-WMIObject -Namespace root\\WebAdministration ApplicationPool;
          $o | where-object {$_.Name -match $ApppoolName }|  Select-object Name,ManagedRuntimeVersion,@{n="State";e={$_.GetState().ReturnValue}  } | format-list
        EOF
        ) do
        its(:stdout) { should match Regexp.new("Name\s+:\s+" + Regexp.quote(app_pool_name)) }
        its(:stdout) { should match Regexp.new('State\s+:\s+1') }
        end
      end
      # TODO
      # try {
      #   Invoke-WmiMethod -ErrorAction Stop -Path '\\IIS\root\WebAdministration:ApplicationPool.Name="DefaultAppPool"' -Name GetState
      # } catch [Exception] {
      #   # TODO: deal with exception
      #   # Invoke-WmiMethod : The RPC server is unavailable. (Exception from HRESULT:
      # }
      #
    end
  end
end
