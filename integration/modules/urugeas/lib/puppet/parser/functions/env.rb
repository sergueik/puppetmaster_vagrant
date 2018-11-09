# origin: https://serverfault.com/questions/127466/how-do-i-access-an-environment-variable-in-a-puppet-manifest
module Puppet::Parser::Functions
  newfunction(:env) do |args|
    variable = args[0]
    $stderr.puts 'Called with ' + args.to_s
    result = ENV.fetch(variable,'undefined')
    $stderr.puts 'Returning ' + result
    result
  end
end
