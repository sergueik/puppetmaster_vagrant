module Serverspec::Type
  class RetryPort < Port
    def retries(max_retries)
      options[:retry] = max_retries
    end
    
    def listening?(protocol, local_address, retries)
      protocol_matcher(protocol) if protocol
      local_address_matcher(local_address) if local_address
      retries(retries) if retries
      @runner.check_port_is_listening_with_retry(@name, options)
    end
  end

  def retry_port(port)
    RetryPort.new(port)
  end
end

include Serverspec::Type

RSpec::Matchers.define :be_listening do
  match do |port|
    port.listening? @with, @local_address, @retries
  end
  
  chain :with do |protocol|
    @with = protocol
  end
  
  chain :on do |local_address|
    @local_address = local_address
  end
  
  chain :with_retry do |retries|
    @retries = retries
  end
end

Specinfra::Command::Windows::Base::Port.class_eval do
  def self.check_is_listening_with_retry(port, options)
    script = <<-EOF
      $ProgressPreference = "SilentlyContinue"
      $retries = 0 + #{options[:retry]};
      $port = #{port}
      0.. $retries | foreach-object {
        $x = & 'netstat' '-ano' '-p' 'TCP';
        $count = @($x | where-object {$_ -match "LISTEN" } | where-object {$_ -match ":${port}" }).count;
        if  ($count -ne 0)  {
          write-output "Port ${port} is listening";
          exit 0;
        } else {
          start-sleep -seconds 30;
        }
      }
      write-output "No access to port ${port}";
      exit 1;
    EOF
    script
  end
end

Specinfra::Command::Base::Port.class_eval do
  def self.check_is_listening_with_retry(port, options)
    script = <<-EOF
      isPortListening() {
        counter=0
        while [ $counter -lt #{options[:retry]} ]; do
          PORT='#{port}'
          /usr/bin/netstat -nta | grep LISTEN | grep -E '(127.0.0.1|0.0.0.0|:::)' | grep ":$PORT" > /dev/null 2>&1
          if [ $? -eq 0 ]; then
            exit 0
          fi
          counter=$((counter+1))
          sleep 30
        done
        exit 1
      }
      isPortListening
    EOF
    script
  end
end

