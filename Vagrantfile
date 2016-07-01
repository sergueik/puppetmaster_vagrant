# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'

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

dir = File.expand_path(File.dirname(__FILE__))

config = {}
vagrantfile_yaml = "#{dir}/Vagrantfile.yaml"
vagrantfile_custom = "#{dir}/Vagrantfile.local"
if File.exists?(vagrantfile_yaml)
  puts "Loading '#{vagrantfile_yaml}'"
  config_yaml = YAML::load_file( vagrantfile_yaml )
  
  box_config = config_yaml[config_yaml[:boot]]
  pp box_config
elsif File.exist?(vagrantfile_custom)
  puts "Loading '#{vagrantfile_custom}'"
  config_legacy = {}
  # config = Hash[File.read(File.expand_path(vagrantfile_custom)).scan(/(.+?) *= *(.+)/)]
  File.read(File.expand_path(vagrantfile_custom)).split(/\n/).each do |line|
    if line !~ /^#/
      key_val = line.scan(/^ *(.+?) *= *(.+) */)
      config_legacy.merge!(Hash[key_val])
    end

  # convert legacy config keys to symbols
  box_config = config_legacy.inject({}) do
    |data,(key,value)| data[key.to_sym] = value
    data 
  end

  end
else
    # TODO: throw an error
end
pp config
unless box_name =~ /\S/
  box_name = box_config[:box_name]
  box_gui = box_config[:box_gui] != nil && box_config[:box_gui].to_s.match(/(true|t|yes|y|1)$/i) != nil
  box_cpus = box_config[:box_cpus].to_i
  box_memory = box_config[:box_memory].to_i
end

if debug
  pp "#{{:box_name => box_name, :box_gui => box_gui, :box_cpus => box_cpus , :box_memory => box_memory}}"
end

VAGRANTFILE_API_VERSION = '2'

centos_bootstrap = <<-EOF

yum list puppet > /dev/null
if [ "$?" == "0" ]
then
   echo "Puppet $(puppet --version) is already installed"
else
   if true
   then
      # echo 'Install Puppet'
      yum -y install puppet
      # echo "Install Puppet 3.1 server"
      # yum -y install ntp
      # chkconfig ntpd on
      # service ntpd start
      # setenforce 0
      # rpm -ivh 'http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm'
      # yum -y install puppet-server
   else
      # this installs Puppet 3.8.1 and Ruby 2.4.7. This is very slow
      cd /tmp
      wget 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
      rpm -Uvh 'epel-release-6-8.noarch.rpm'
      yum -y update
      yum -y groupinstall 'Development Tools'
      yum -y install libxslt-devel libyaml-devel libxml2-devel zlib-devel openssl-devel libyaml-devel readline-devel curl-devel openssl-devel git
      yum -y install rubygems
      gem install puppet --no-ri --no-rdoc --version 3.8.1 --bindir /usr/bin
   fi
fi


EOF

windows_bootstrap = <<-EOF

& echo "Running Facter"
& facter.bat hostname
& echo "Installing puppetlabs-powershell from Puppet Forge"
& puppet.bat module install puppetlabs-powershell

EOF

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

  # Localy cached images from http://www.vagrantbox.es/ and  http://dev.modern.ie/tools/vms/linux/

  config_vm_newbox = box_config[:config_vm_newbox]
  config_vm_box = box_config[:config_vm_box]
  config_vm_default = box_config[:config_vm_default]
  config_vm_box_name = box_config[:config_vm_box_name]

  config_vm_box_url = "file://#{basedir}/Downloads/#{config_vm_box_name}"
  config.vm.define config_vm_default do |config|
      config.vm.box = config_vm_box
      config.vm.box_url  = config_vm_box_url
      puts "Configuring '#{config.vm.box}'"
      # Configure guest-specific port forwarding
      if config.vm.box !~ /windows/
        if config.vm.box =~ /centos/
          config.vm.network 'forwarded_port', guest: 8080, host: 8080, id: 'artifactory', auto_correct:true
        end
        config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc', auto_correct: true
        config.vm.host_name = 'linux.example.com'
        config.vm.hostname = 'linux.example.com'
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
        vb.customize ['modifyvm', :id, '--ioapic', 'on'] 
        vb.customize ['modifyvm', :id, '--audio', 'none']
        vb.customize ['modifyvm', :id, '--usb', 'off']
      end

      # Provision software
      puts "Provision software for '#{config.vm.box}'"
      case config_vm_box
        when /centos/
          if config_vm_newbox
            # Use shell provisioner to install latest puppet
            config.vm.provision 'shell', inline: centos_bootstrap
          end
          puppet_options = if debug then '--verbose --modulepath /vagrant/modules --pluginsync --debug' else '--verbose --modulepath /vagrant/modules --pluginsync' end 
          config.vm.provision :puppet do |puppet|
            # for not using module_data
            # http://blog.wilcoxd.com/2015/03/02/a-deep-dive-into-vagrant-puppet-and-hiera/
            puppet.hiera_config_path = 'data/hiera.yaml'
            puppet.module_path    = 'modules'
            puppet.manifests_path = 'manifests'
            puppet.manifest_file  = 'linux.pp'
            puppet.options        = puppet_options
          end
        when /ubuntu/
          if config_vm_newbox
            # Use shell provisioner to install latest puppet
            # config.vm.provision 'shell', path: 'bootstrap.sh'
          end
          config.vm.provision :shell, :path=> '/usr/bin/facter hostname'

          # Use puppet provisioner
          config.vm.provision :puppet do |puppet|
            puppet.hiera_config_path = 'data/hiera.yaml'
            puppet.module_path    = 'modules'
            puppet.manifests_path = 'manifests'
            puppet.manifest_file  = 'linux.pp'
            puppet.options        = '--verbose --pluginsync'
          end
        else
          if config_vm_newbox
            config.vm.provision :shell, :path => 'bootstrap_legacy.cmd'
            # install .Net 4
            config.vm.provision :shell, :path => 'install_net4.ps1'
            # install chocolatey
            config.vm.provision :shell, :path => 'install_chocolatey.ps1'
            # install puppet using chocolatey
            config.vm.provision :shell, :path => 'install_puppet.ps1'
            # run facter
            # NOTE: error from Vagrant: 
            # The splatting operator '@' cannot be used to reference variables in an expression. 
            # '@puppet' can be used only as an 
            # argument to a command. To reference variables in an expression use '$puppet'.
            config.vm.provision :shell, :inline => windows_bootstrap
          end
          # Use chef provisioner
          # config.vm.provision :chef_solo do |chef|
          #   chef.version = '12.5.1'
          #   chef.data_bags_path = 'data_bags'
          #   chef.add_recipe 'custom_powershell'
          # end 
          # Use puppet provisioner
          config.vm.provision :puppet do |puppet|
            puppet.binary_path    = 'C:/PROGRA~1/PUPPET~1/PUPPET/bin'
            puppet.hiera_config_path = 'data/hiera.yaml'
            puppet.module_path    = 'modules'
            puppet.manifests_path = 'manifests'
            puppet.manifest_file  = 'windows.pp'
            puppet.options        = '--verbose'
            # TODO: http://puppet-on-the-edge.blogspot.com/2014/03/heredoc-is-here.html
            # puppet.options        = '--verbose --parser'
          end
      end
      config.vm.provision :serverspec do |spec|
        spec.pattern = 'spec/linux/*_spec.rb'
          # NOTE: cannot process results of the backend command e.g
          # Failure/Error: 
          # SystemStackError:
          # stack level too deep
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:7:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/configuration.rb:38:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:16:in `detect_os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:9:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/configuration.rb:38:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:16:in `detect_os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:9:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/configuration.rb:38:in `os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:16:in `detect_os'
          # C:/Users/Serguei/.vagrant.d/gems/gems/specinfra-2.59.4/lib/specinfra/helper/os.rb:9:in `os'

      end
    end
end
