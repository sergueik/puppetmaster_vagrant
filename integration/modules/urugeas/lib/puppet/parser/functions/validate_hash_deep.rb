# based on:https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/lib/puppet/parser/functions/validate_hash_deep.rb
#
# validate_hash_deep.rb
#
module Puppet::Parser::Functions
  newfunction(:validate_hash_deep, :doc => <<-'DOC') do |args|
  documentation of the validate_hash_deep function.
  The following will fail

  validate_hash_deep({
    'first' =>
      {
        'foo' => 1,
        'bar' => 1,
      },
    'second' =>
      {
        'foo' => 1,
        'bad' => 1, # no 'bar' key
      },
      'bad' => 'string', # not a hash in val
    })

    DOC
    args.each do |arg|
      unless arg.is_a?(Hash)
        raise Puppet::ParseError, "#{arg.inspect} is not a Hash.  It looks to be a #{arg.class}"
      end
      arg.each do |key,val|
	# val will be a hash
        $stderr.puts "DEBUG: " + key + ' = ' + val.to_s
	unless val.is_a?(Hash)
	raise Puppet::ParseError, "The schema of #{val.inspect} is incorrect."
	end
	['foo','bar'].each do |control_key|
          unless val.keys.include? control_key
            raise Puppet::ParseError, "The schema of #{val.inspect} is incorrect. The '#{control_key}' key must be defined"
      	  end
	end
      end
    end
  end
end
