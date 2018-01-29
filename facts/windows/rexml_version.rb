puppet_lib_home='C:/Program Files/Puppet Labs/Puppet' # for windows
$LOAD_PATH.insert(0, "#{puppet_lib_home}/facter/lib") # absent for some enterprise custom build boxes?
$LOAD_PATH.insert(0, "#{puppet_lib_home}/hiera/lib")
$LOAD_PATH.insert(0, "#{puppet_lib_home}/puppet/lib")

require 'yaml'
require 'puppet'
require 'facter'
require 'pp'
require 'optparse'
require 'rexml/document'
include REXML

# name of the custom fact
fact_name = 'rexml_version'
# code of the fact to follow
$DEBUG = false
def rexml_get_version
  result = nil
  file_path = 'version.xml'
  if File.exists?(file_path)
    begin
      file = File.new(file_path)
    rescue => ex
      $stderr.puts ex.to_s
      # throw ex
    end
    doc = Document.new(file)
    # TODO: assert
    # puts doc.version if $DEBUG
    result = doc.root.elements['Product'].attributes['version']
  end
end
def powershell_xml_get_version
  result = nil
  file_path = 'version.xml'
  if File.exists?(file_path)
    begin
      script = "([xml](get-content -path '#{file_path}')).Info.Product.version"
      $stderr.puts "script: #{script}" if $DEBUG
      command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -command \" & { #{script} }\""
      $stderr.puts "command: #{command}" if $DEBUG
      result = Facter::Util::Resolution.exec(command)
    rescue => ex
      $stderr.puts ex.to_s
      # throw ex
    end
  end
end

begin  
  Facter.add(fact_name) do
    setcode do
      rexml_get_version
      powershell_xml_get_version
    end
  end
  # end of custom fact
  puts "#{fact_name} = '#{Facter.value(fact_name.to_sym)}'"
rescue => e
  $stderr.puts 'Exception:' + e.to_s
end
