require 'json'

module Serverspec # :nodoc:
  module Type # :nodoc:
    class EventLog < Base # :nodoc:
      def initialize(args)
        super
        @user      = args[:user]
        @directory = args[:directory]
        @base_cmd  = << EOF        
        $event_log_id = '#{event_log_id}'
        $log_name = '#{log_name}'
        if ($log_name -eq '' ) { 
          $log_name = 'Application'
        }
        if ($event_log_id -eq '' ) { 
          $event_log_id = '10001'
        }
        get-winevent -FilterHashTable @{LogName=$log_name; ID=$event_log_id; } -MaxEvents 10 |
        sort-object TimeCreated -descending |
        select-object -first 1 |
        select-object -property Message |
        ConvertTo-Json -Depth 10
        EOF  
      end
      
      # TODO: change to meaninfgul parameters 
      def has_enabled_app?(app, version)
        params = %(app:list | egrep "#{app}: )
        params << %(.*#{version}) if version
        params << %("')
        ret = run_powershell_command_with(params)
        (ret.exit_status == 0 ? true : false)
      end

      def has_disabled_app?(app)
        params = %(app:list | egrep "#{app}$")
        params << "'"
        ret = run_powershell_command_with(params)
        (ret.exit_status == 0 ? true : false)
      end

      def has_configuration?(key, val)
        params  = %(config:system:get #{key}')
        ret     = run_powershell_command_with(params)
        ret_val = ret.stdout.strip
        val = (val.nil? ? '' : val)
        ret_val = (val.class == Fixnum ? ret_val.to_i : ret_val)
        if ret_val.match(val)
          return true
        else
          return false
        end
      end

      private

      def run_powershell_command_with(params)
        @runner.run_command(@base_cmd + params)
      end
    end
    def get_data
      @content  = Specinfra::Runner::run_command( @base_cmd ).stdout
      @data = JSON.parse(@content)
    end
    def to_s
      # TODO 
      'EventLog'
    end
    def event_log(file)
      EventLog.new(file)    
    end
  end
end

# Ruby code to build a rspec-friendly custom data type 
# origin: [ Serverspec+ by uroesh](https://github.com/uroesch/serverspec_plus)
