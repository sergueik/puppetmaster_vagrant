 #!/usr/bin/env ruby
 require 'facter'
 
 fact_name = 'mongod_service_is_running'
 if Facter.value(:kernel) == 'Linux'
   service_name = 'mongod.service'
   command = "/bin/systemctl status ${service_name}"
   command_output = Facter::Util::Resolution.exec(command)
   if ! command_output.nil?
     result = command_output.split(/\r?\n/).grep(Regexp.escape('active (running)'))
   end
 end
 if result != ''
   Facter.add(fact_name)
   do
     setcode { true }
   end
 end
