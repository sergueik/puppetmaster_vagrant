 #!/usr/bin/env ruby
require 'facter'

# Exposing for the service state as a node fact may be useful in combination with
# Puppet transition module https://github.com/puppetlabs/puppetlabs-transition

service_name = 'mongod.service'
fact_name = "#{service_name.gsub('.','_')}_is_enabled"
if Facter.value(:kernel) == 'Linux'
  command = "/bin/systemctl list-unit-files| /bin/grep -E \"^#{service_name}\""
  command_output = Facter::Util::Resolution.exec(command)
  if ! command_output.nil?
    result = command_output.split(/\r?\n/).grep(/^#{service_name}.*$/)
  end
end
if result != []
  # $stderr.puts "#{fact_name}: '#{result}"
  Facter.add(fact_name)
  do
    setcode { true }
  end
end
