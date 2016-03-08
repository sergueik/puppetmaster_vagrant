class Specinfra::Command::Windows::Base::YamlFile< Specinfra::Command::Windows::Base
  class << self
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
