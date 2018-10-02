require 'spec_helper'
require 'pp'
require 'json'
require 'yaml'

# Performs data extraction from YAML with the help of jq
# https://medium.com/@frontman/how-to-parse-yaml-string-via-command-line-374567512303
# Alternatively
# https://github.com/kislyuk/yq
# (in Python)
# for Debian based
# sudo add-apt-repository ppa:rmescandon/yq
# sudo apt update
# sudo apt install yq -y
# for HTML see also
# https://github.com/ericchiang/pup
# (in go)

context 'Using jq to proces YAML' do
  datafile = '/tmp/sample.yaml'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      # indent and white space matters
      cat<<END>#{datafile}
---
node-ad8c3125:
  datacenter: 'miami'
  consul_node_name: consul-service-discovery-server
  branch_name: 'uat'
  environment: 'prod'
  dc: 'bcp'
  param1: 
    - 'a'
    - 'b'
    - 'c'
  param2: 
    key1: 'value1'
    key2: 'value2'
  param3: 'data'
END
    EOF
    )
  end
  describe command(<<-EOF
    cat '#{datafile}' | ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' | \\
    jq '.[]| select( .datacenter | contains("miami")) | .param1 | @csv '

  EOF
  ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('"\\\\"a\\\\",\\\\"b\\\\",\\\\"c\\\\"', Regexp::IGNORECASE) }
      its(:stderr) { should_not match 'jq: error: syntax error' }
  end
end