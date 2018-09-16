begin
  klas = Inspec::Resources::JsonConfig
rescue
  klas = JsonConfig
end

class NodeAttributes < klas
  name 'node'
  def initialize
    super('/tmp/node.json')
  end
end
