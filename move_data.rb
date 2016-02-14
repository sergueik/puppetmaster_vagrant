require 'yaml'
require 'pp'

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
  config = config_yaml[config_yaml['boot']]
elsif File.exist?(vagrantfile_custom)
  puts "Loading '#{vagrantfile_custom}'"
  # config = Hash[File.read(File.expand_path(vagrantfile_custom)).scan(/(.+?) *= *(.+)/)]
  File.read(File.expand_path(vagrantfile_custom)).split(/\n/).each do |line|
    if line !~ /^#/
      key_val = line.scan(/^ *(.+?) *= *(.+) */)
      config.merge!(Hash[key_val])
    end
  end
else
    # TODO: throw an error
end

box_name = config['box_name']
box_gui = config['box_gui'] != nil && config['box_gui'].to_s.match(/(true|t|yes|y|1)$/i) != nil
box_cpus = config['box_cpus'].to_i
box_memory = config['box_memory'].to_i

if debug
  # convert keys to symbols
  config_obj = config.inject({}) do
    |data,(key,value)| data[key.to_sym] = value
    data 
  end
  pp config_obj
end
pp config_yaml
# probably no need in an extra layer 
# pp config_yaml['vagrant_boxes']
# return
# config_yaml['vagrant_boxes'].each do |box_name, box_data|
config_yaml.each do |box_name, box_data|
  if box_name =~ /boot/
    next
  end
  puts box_name
  config_vm_box_name = nil
  config_vm_box = nil
  config_vm_default = nil 
  config_vm_newbox  = false
  case box_name
    when /centos65_i386/
      config_vm_box      = 'centos'
      config_vm_default  = 'linux'
      config_vm_box_name = 'centos_6-5_i386.box'
    when /centos66_x64/
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      config_vm_box_name  = 'centos-6.6-x86_64.box'
    when /centos65_x64/  # Puppet not preinstalled
      config_vm_newbox  = true
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      config_vm_box_name = 'centos-6.5-x86_64.box'
    when /centos7/
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      config_vm_box_name = 'centos-7.0-x86_64.box'
    when /trusty32/
      config_vm_box      = 'ubuntu'
      config_vm_default  = 'linux'
     config_vm_box_name = 'trusty-server-cloudimg-i386-vagrant-disk1.box'
    when /trusty64/
      config_vm_box      = 'ubuntu'
      config_vm_default  = 'linux'
      config_vm_box_name = 'trusty-server-cloudimg-amd64-vagrant-disk1.box'
    when /precise64/
      config_vm_box      = 'ubuntu'
      config_vm_default  = 'linux'
      config_vm_box_name = 'ubuntu-server-12042-x64-vbox4210.box'
    else
      config_vm_default = 'windows'
      # set config_vm_newbox to true when importing for the first time
      # config_vm_newbox  = false
      if box_name =~ /xp/
        config_vm_box      = 'windows_xp'
        config_vm_box_name = 'IE8.XP.For.Vagrant.box'
      elsif box_name =~ /2008/
        config_vm_box      = 'windows_2008'
        config_vm_box_name = 'windows-2008R2-serverstandard-amd64_virtualbox.box'
      # https://atlas.hashicorp.com/opentable/boxes/win-2008r2-standard-amd64-nocm/versions/1.0.1/providers/virtualbox.box
      elsif box_name =~ /2012/
        config_vm_box     = 'windows_2012'
        config_vm_box_name = 'windows_2012_r2_standard.box'
      elsif box_name =~ /windows10/
        # config_vm_newbox  = true
        config_vm_box     = 'windows10'
        config_vm_box_name = 'vagrant-win10-edge-default.box'
      elsif box_name =~ /windows_winrm/
        # config_vm_newbox  = true
        config_vm_box     = 'windows_winrm'
        config_vm_box_name = 'windows10_winrm_configured_repackaged.box'
      else
        config_vm_newbox  = true
        config_vm_box     = 'windows7'
        config_vm_box_name = 'vagrant-win7-ie10-updated.box'
        # https://atlas.hashicorp.com/ferventcoder/boxes/win7pro-x64-nocm-lite
        # config_vm_box_name = 'win7pro-x64-nocm-lite.box'
        # broken winrm

      end
   end

begin
  box_data['config_vm_newbox'] = config_vm_newbox
  box_data['config_vm_default'] = config_vm_default
  box_data['config_vm_box'] = config_vm_box
  box_data['config_vm_box_name'] = config_vm_box_name
rescue

end
pp box_data

  box_data_obj = box_data.inject({}) do
    |data,(key,value)| data[key.to_sym] = value
    data 
  end

config_yaml[box_name] = box_data_obj
end

if debug
  # convert keys to symbols
  config_obj = config_yaml.inject({}) do
    |data,(key,value)| data[key.to_sym] = value
    data 
  end
  pp config_obj
end


puts config_obj.to_yaml
