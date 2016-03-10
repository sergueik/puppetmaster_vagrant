class Specinfra::Command::Windows::Base::YamlFile< Specinfra::Command::Windows::Base
  class << self
    # To inspect last_run_report locally, load puppet libraries
    puppet_home = 'c:/Program Files/Puppet Labs/Puppet'
    $LOAD_PATH.insert(0, "#{puppet_home}/facter/lib")
    $LOAD_PATH.insert(0, "#{puppet_home}/hiera/lib")
    $LOAD_PATH.insert(0, "#{puppet_home}/puppet/lib")
    $LOAD_PATH.insert(0, "#{puppet_home}/sys/ruby")
    # need to install locally win32-dir, win32-security, win32-process,win32-service
    # the other option is to have two YamlFile classes and run Backend::Exec / Backend::Cmd
    rubyopt = 'rubygems'    
    require 'yaml'
    require 'puppet' 
    require 'pp'
    def check_has_resource(name, resource_name, resource_type)
      cmd = generate_command name, resource_name, resource_type, 'FindResource'
      Backend::PowerShell::Command.new do
        using 'yaml_serializer2.ps1'
        exec cmd
      end
    end
    def check_has_message(name, message)
      cmd = generate_command name, message, 'FindMessage'
      Backend::PowerShell::Command.new do
        using 'yaml_serializer2.ps1'
        exec cmd
      end
    end
    def check_has_resource_message(name, resource_name, resource_type, message)
      cmd = generate_command name, resource_name, resource_type, message, 'FindResourceEventMessage'
      Backend::PowerShell::Command.new do
        using 'yaml_serializer2.ps1'
        exec cmd
      end
    end
    private
    def generate_command item, value, attribute
     # 	"FindResourceEventMessage '#{name}' -name '#{resource_name}' -type '#{resource_type}' -message '#{message_message}'"
     # "FindResource -log '#{name}' -name '#{resource_name}' -type '#{resource_type}'"
     # "FindMessage -log '#{name}' -message '#{message}'" [-source '#{source}']
    end
  end
end
