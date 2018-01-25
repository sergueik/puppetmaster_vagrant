require 'rexml/document' 
include REXML 
# name of the custom fact
fact_name = 'rexml_version'
# code of the fact to follow
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
    # puts doc.version
    result = doc.root.elements['Product'].attributes['version']
  end
end
Facter.add(fact_name) do
  setcode do
    rexml_get_version
  end
end
