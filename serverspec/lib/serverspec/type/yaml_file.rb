module Serverspec::Type
  class YamlFile< Base

    def exists?()
      1;
    end

    def has_message?(text)
      @runner.check_yaml_file_has_message(@name, text)
    end

    def has_resource?( resource_name, resource_type)
      @runner.check_yaml_file_has_resource(@name, resource_name, resource_type )
    end
      
    def has_resource_message?(resource_name, resource_type, text)
      @runner.check_yaml_file_has_resource_message(@name, resource_name, resource_type, text)
    end

    def to_s
      %Q[Puppet Last Run Log "#{@name}"]
    end
  end
end
