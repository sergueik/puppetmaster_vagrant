require_relative '../windows_spec_helper'

context 'IIS App Pools' do

  describe command( <<-EOF
  [Xml]$raw_data = invoke-expression -command 'C:\\Windows\\system32\\inetsrv\\appcmd.exe list apppool /xml';

  # puppet module also uses appcmd.exe
  # https://github.com/simondean/puppet-iis/tree/master/lib/puppet/type
  # puppet module uses WebAdministration 
  # https://github.com/puppet-community/puppet-iis/blob/master/manifests/manage_app_pool.pp
 
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
end
