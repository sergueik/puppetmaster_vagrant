# -*- mode: ruby -*-
# vi: set ft=ruby :

# Custom environment settings to enable this Vagrantfile to boot various flavours of Linux or Windows from Linux or Windows host
vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy = ENV.fetch('HTTP_PROXY', nil) 
# Found that on some hosts ENV.fetch does not work 
box_name = ENV.fetch('BOX_NAME', '') 
debug = ENV.fetch('DEBUG', 'false') 
box_memory = ENV.fetch('BOX_MEMORY', '') 
box_cpus = ENV.fetch('BOX_CPUS', '') 
box_gui = ENV.fetch('BOX_GUI', '') 
debug = (debug =~ (/^(true|t|yes|y|1)$/i))

unless box_name =~ /\S/
  # Load custom vagrant config
  custom_vagrantfile = 'Vagrantfile.local'
  if File.exist?(custom_vagrantfile) 
    puts "Loading '#{custom_vagrantfile}'"
    # shorti-circuit for single-entry configs
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
    # Load configuration 
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

basedir =  ENV.fetch('USERPROFILE', '')  
basedir  = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

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

  # Localy cached images from
  # http://www.vagrantbox.es/
  # http://dev.modern.ie/tools/vms/linux/
  # TODO: make precise the default
  config.vm.hostname = 'puppet.vagrantbox.local'
  case box_name 
    when /trusty32/ 
      config.vm.box = 'ubuntu/trusty32'
      config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
    when /trusty64/ 
      config.vm.box = 'ubuntu/trusty64'   
      config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    when /precise64/ 
      config.vm.box = 'ubuntu/precise64'
      config.vm.box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
    else 
      # tweak modern.ie image into a vagrant manageable box
      # https://gist.github.com/uchagani/48d25871e7f306f1f8af
      # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
      config.vm.box = 'windows7'
      config.vm.box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
  end
  # Configure guest-specific port forwarding
  if config.vm.box !~ /windows/ 
    config.vm.network 'forwarded_port', guest: 80, host: 8080, id: 'apache', auto_correct:true
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
    when /ubuntu|debian/
      # Use shell provisioner to install latest puppet
      config.vm.provision 'shell', path: 'bootstrap.sh'
      config.vm.provision :shell, :path=> '/usr/bin/facter'
      # Use puppet provisioner
      config.vm.provision :puppet do |puppet|
        puppet.module_path    = 'modules'
        puppet.manifests_path = 'manifests'
        puppet.manifest_file  = 'default.pp'
        puppet.options        = '--verbose --modulepath /vagrant/modules'
      end 
    else
      # Use shell provisioner to install .Net 4 and chocolatey
      config.vm.provision :shell, :path => 'bootstrap.cmd'
      # use chocolatey to install puppet
      config.vm.provision :shell, inline: <<-END_SCRIPT1
$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
cinst.exe --yes puppet
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

