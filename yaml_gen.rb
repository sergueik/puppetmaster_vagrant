#! env ruby
# NOTE: some corrupt files were difficult to recover manually,
# semi possible to load and dump using YAML class.
# based on
# https://stackoverflow.com/questions/20839230/how-can-i-write-quoted-values-in-en-yml
#

require 'yaml'
require 'optparse'
require 'pp'

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
if $DEBUG
  @inputs = { :IN_FILE => $IN_FILE, :OUT_FILE => $OUT_FILE }
  pp @inputs
end
y = YAML.load_file($IN_FILE)
# def unsuccessful_value_stringify(_hash)
#   _hash.each do |_key,_value|
#     if _value.kind_of? Hash
#       _hash[_key] = unsuccessful_value_stringify(_value)
#     else
#       _hash[_key] = "#{_value}--EXTRA SPACE--"
#     end
#   end		
# end
#
# File.open($OUT_FILE, 'w') do |_file|
#   _file.write(unsuccessful_value_stringify(y).to_yaml.gsub('--EXTRA SPACE--', ''))
# end
# will lose the quotes around values
def value_stringify(_hash)
  _hash.each do |_key,_value|
    if _value.kind_of? Hash
      _hash[_key] = value_stringify(_value)
    else
      if _value.kind_of? String
        _hash[_key] = "'#{_value}'"
      end
    end
  end		
end

File.open($OUT_FILE, 'w') do |_file|
  _file.write(value_stringify(y).to_yaml.gsub(/(\'\"|\"\')/, '"'))
end
# NOTE: original vertsion of stackoverflow 
# adds quotes around boolean and numeric too
# like
#
#  cat a.yaml
#  ---
#  :boot: "windows 7"
#  trusty_32:
#    :box_name: "trusty 32"
#    :box_memory: "512"
#    :box_cpus: 1
#    :box_gui: false
#    :config_vm_newbox: true
#    :config_vm_default: "windows"
#    :config_vm_box: "windows 7"
#    :config_vm_box_name: "trusty-server-cloudimg-i386-vagrant-disk1.box"
#
#  ruby yaml_gen.rb  --in a.yaml  --out b.yaml
#
#  cat b.yaml
#  :boot: "windows 7"
#  trusty_32:
#    :box_name: "trusty 32"
#    :box_memory: "512"
#    :box_cpus: 1
#    :box_gui: false
#    :config_vm_newbox: true
#    :config_vm_default: "windows"
#    :config_vm_box: "windows 7"
#    :config_vm_box_name: "trusty-server-cloudimg-i386-vagrant-disk1.box"
#
