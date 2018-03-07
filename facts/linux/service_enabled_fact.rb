 #!/usr/bin/env ruby
require 'facter'

fact_name = 'mongod_service_is_enabled'
if Facter.value(:kernel) == 'Linux'
  service_name = 'mongod.service'
  command = "/bin/systemctl list-unit-files| /bin/grep -E \"^#{service_name}\""
  command_output = Facter::Util::Resolution.exec(command)
  if ! command_output.nil?
    result = command_output.split(/\r?\n/).grep(/^#{service_name}.*$/)
  end
end
if result != []
  Facter.add(fact_name)
  do
    setcode { true }
  end
end
