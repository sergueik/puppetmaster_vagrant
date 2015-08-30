# -*- mode: ruby -*-
# vi: set ft=ruby :

basedir = ENV.fetch('USERPROFILE', '')  
basedir = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy        = ENV.fetch('HTTP_PROXY', nil) 
box_name          = ENV.fetch('BOX_NAME', '') 
debug             = ENV.fetch('DEBUG', 'false') 
box_memory        = ENV.fetch('BOX_MEMORY', '') 
box_cpus          = ENV.fetch('BOX_CPUS', '') 
box_gui           = ENV.fetch('BOX_GUI', '') 
debug             = (debug =~ (/^(true|t|yes|y|1)$/i))

unless box_name =~ /\S/
  custom_vagrantfile = 'Vagrantfile.local'
  if File.exist?(custom_vagrantfile) 
    puts "Loading '#{custom_vagrantfile}'"
    # config = Hash[File.read(File.expand_path(custom_vagrantfile)).scan(/(.+?) *= *(.+)/)]
    config = {}
    File.read(File.expand_path(custom_vagrantfile)).split(/\n/).each do |line| 
      if line !~ /^#/
        key_val = line.scan(/^ *(.+?) *= *(.+) */)
        config.merge!(Hash[key_val])
      end
    end
    if debug
      puts config.inspect
    end
    box_name = config['box_name']
    box_gui = config['box_gui'] != nil && config['box_gui'].match(/(true|t|yes|y|1)$/i) != nil
    box_cpus = config['box_cpus'].to_i
    box_memory = config['box_memory'].to_i
  else
    # TODO: throw an error
  end
end 

if debug
  puts "box_name=#{box_name}"
  puts "box_gui=#{box_gui}"
  puts "box_cpus=#{box_cpus}"
  puts "box_memory=#{box_memory}"
end

VAGRANTFILE_API_VERSION = '2'
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Configure Proxy authentication

  if vagrant_use_proxy
    if http_proxy
    
      if Vagrant.has_plugin?('vagrant-proxyconf')
        # Windows-specific case
        # A proxy should be specified in the form of http://[user:pass@]host:port.
        # without the domain part and with percent signs doubled - Vagrant and Ruby still use batch files on Windows
        # https://github.com/tmatilai/vagrant-proxyconf
        # https://github.com/WinRb/vagrant-windows
        config.proxy.http     = http_proxy.gsub('%%','%')
        config.proxy.https    = http_proxy.gsub('%%','%')
        config.proxy.no_proxy = 'localhost,127.0.0.1'
      end
    end 
  end

  config.vm.hostname = 'puppet.vagrantbox.local'

  # Localy cached images from http://www.vagrantbox.es/ and  http://dev.modern.ie/tools/vms/linux/
  case box_name 
   when /centos6/ 
     config.vm.box      = 'centos/65'
     config.vm.box_url  = "file://#{basedir}/Downloads/centos-6.5-x86_64.box"
   when /centos7/ 
     config.vm.box      = 'centos/7'
     config.vm.box_url  = "file://#{basedir}/Downloads/centos-7.0-x86_64.box"
    when /trusty32/ 
      config.vm.box     = 'ubuntu/trusty32'
      config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
    when /trusty64/ 
      config.vm.box     = 'ubuntu/trusty64'   
      config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    when /precise64/ 
      config.vm.box     = 'ubuntu/precise64'
      config.vm.box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
    else 
      # tweak modern.ie image into a vagrant manageable box
      # https://gist.github.com/uchagani/48d25871e7f306f1f8af
      # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
      config.vm.box     = 'windows7'
      config.vm.box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
  end
  # Configure guest-specific port forwarding
  if config.vm.box !~ /windows/ 
    if config.vm.box =~ /centos/ 
      config.vm.network 'forwarded_port', guest: 8080, host: 8080, id: 'artifactory', auto_correct:true
    end
    config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc', auto_correct: true
    config.vm.host_name = 'vagrant-chef'
    # config.vm.synced_folder 'puppet/manifests', '/etc/puppet/manifests'
    # config.vm.synced_folder 'puppet/modules', '/etc/puppet/modules'
    # config.vm.synced_folder 'puppet/hieradata', '/etc/puppet/hieradata'
  else
    # have to clear HTTP_PROXY to prevent
    # WinRM::WinRMHTTPTransportError: Bad HTTP response returned from server (503) 
    # https://github.com/chef/knife-windows/issues/143
    ENV.delete('HTTP_PROXY')
    # NOTE: WPA dialog blocks chef solo and makes Vagrant fail on modern.ie box
    config.vm.communicator      = 'winrm'
    config.winrm.username       = 'vagrant'
    config.winrm.password       = 'vagrant'
    config.vm.guest             = :windows
    config.windows.halt_timeout = 15
    # Port forward WinRM and RDP
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct:true
    config.vm.host_name         = 'windows7'
    config.vm.boot_timeout      = 120
    # Ensure that all networks are set to 'private'
    config.windows.set_work_network = true
    # on Windows, use default data_bags share
  end
  # Configure common synced folder
  config.vm.synced_folder './' , '/vagrant'
  # Configure common port forwarding
  config.vm.network 'forwarded_port', guest: 4444, host: 4444, id: 'selenium', auto_correct:true
  config.vm.network 'forwarded_port', guest: 3000, host: 3000, id: 'reactor', auto_correct:true
  
  config.vm.provider 'virtualbox' do |vb|
    vb.gui = box_gui 
    vb.customize ['modifyvm', :id, '--cpus', box_cpus ]
    vb.customize ['modifyvm', :id, '--memory', box_memory ]
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    vb.customize ['modifyvm', :id, '--accelerate3d', 'off']
    vb.customize ['modifyvm', :id, '--audio', 'none']
    vb.customize ['modifyvm', :id, '--usb', 'off']
  end

  # config.berkshelf.berksfile_path = 'cookbooks/wrapper_java/Berksfile'
  # config.berkshelf.enabled = true

  # Provision software
  # Provision software
  case config.vm.box.to_s 
    when /ubuntu|centos/
      # Use shell provisioner to install latest puppet
      config.vm.provision 'shell', inline: <<-EOF 
/usr/bin/env python -mplatform | grep -qi ubuntu
if [  "$?" -eq "0" ]
then
IS_UBUNTU=true
/vagrant/bootstrap.sh
else
echo ''
## this is for cpan module which is not supported on RH anyway
## yum -y install expat-devel
## yum -y install perl-CPAN
## https://tickets.puppetlabs.com/si/jira.issueviews:issue-html/PUP-2940/PUP-2940.html
## gem install puppet --version 3.8.1 --bindir /usr/bin
fi
     EOF
      config.vm.provision :shell, :path=> '/usr/bin/facter'
      # Use puppet provisioner
      config.vm.provision :puppet do |puppet|
        puppet.module_path    = 'modules'
        # Could not parse application options: invalid option: --manifestdir
        # on CentOS7
        # puppet.manifests_path = 'manifests'
        # puppet.manifest_file  = 'linux.pp'
        # puppet.options        = '--verbose --modulepath /vagrant/modules '
        puppet.options        = '--verbose --modulepath /vagrant/modules /vagrant/manifests/default.pp'
      end 
    else
      # Use shell provisioner to install .Net 4 and chocolatey
      config.vm.provision :shell, :path => 'bootstrap.cmd'
      # use chocolatey to install puppet
#  NOTE: chocolatey detects that puppet is installed, faster 
      config.vm.provision :shell, inline: <<-END_SCRIPT1


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

# The following seems to queryy the host environment, instead of guest
if (-not [environment]::Is64BitProcess) {
   $registry_path  = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall'
} else {
   $registry_path = '/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall'
}

# Finging install info for Puppet
$Debugpreference = 'Continue'
$package_name = 'Puppet'
$install_path = read_registry -subfolder 'bin' -registry_path $registry_path -package_name $package_name -Debug $true
if ($install_path -ne $null -and $install_path -ne '' -and (test-path -path $install_path)) { 
  write-output ('{0} is already installed to {1}' -f $package_name, $install_path )
} else {
  $env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
  cinst.exe --yes puppet 
}
      END_SCRIPT1
      config.vm.provision :shell, inline: <<-END_SCRIPT2
$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
facter.bat
      END_SCRIPT2
      # Use puppet provisioner
      config.vm.provision :puppet do |puppet|
        puppet.module_path    = 'modules'
        puppet.manifests_path = 'manifests'
        puppet.manifest_file  = 'windows.pp'
        puppet.options        = '--verbose --modulepath=/vagrant/modules'
      end 
  end 
end

