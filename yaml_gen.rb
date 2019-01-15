#! env ruby
# NOTE: some corrupt files were difficult to recover manually, 
# semi possible to load and dump using YAML class.
# based on 
# https://stackoverflow.com/questions/20839230/how-can-i-write-quoted-values-in-en-yml
#

require 'csv'
require 'yaml'
require 'json'
require 'optparse'

o = OptionParser.new

@options = {
  :debug => false,
  :in    => 'corrupt.yaml',
  :out   => 'fixed.yaml',
}

o.on('--in [FILENAME]', 'possibly corruptfile to read YAML') do |val|
  @options[:in_file] = val
end

o.on('--out [FILENAME]', 'filename to save recovered yaml') do |val|
  @options[:out_file] = val
end


o.on('--debug', 'Debug') do |val|
  @options[:debug] = val
end

o.parse!
$DEBUG = @options[:debug]
$IN_FILE = @options[:in_file]
$OUT_FILE = @options[:out_file]

y = YAML.load_file($IN_FILE)
def value_stringify(_hash)
  _hash.each do |_key,_value|
    if _value.kind_of? Hash
      _hash[_key] = value_stringify(_value) 
    else
      _hash[_key] = "'#{_value}'"
    end
  end		

end


File.open($OUT_FILE, 'w') do |_file|
  _file.write(value_stringify(y).to_yaml)
end
