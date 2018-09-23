require 'spec_helper'

RSpec.describe docker_container('consul') do
  it { should exist }
  it { should be_running }
  it { should have_image('consul') }
  it { should run_as_user '' }
  it { should map_port('8500', '8500') }
  it { should have_restart_policy('always') }
  it { should have_restart_limit(0) }
  it { should have_hostname('consul') }
  it { should have_domainname('') }
  it { should_not be_privileged }
  it { should_not publish_all_ports }
  it { should have_host('169.254.1.1 leek') }
  it { should have_environment_variable 'CONSUL_VERSION' }
  it { should have_environment_variable('HASHICORP_RELEASES').with_value('https://releases.hashicorp.com') }
  # TODO: Label Matcher
end

#Get container by name
RSpec.describe docker_container('haproxy') do
  it { should exist }
  it { should be_running }
  it { should have_image('dockercloud/haproxy') }
  it { should run_as_user '' }
  it { should map_port('15672', '15672') }
  it { should have_mount('/var/run/docker.sock', '/var/run/docker.sock') }
end

#get conatiner by filter
RSpec.describe docker_container('Name=vagrant_rabbit') do
  it { should exist }
end

RSpec.describe docker_service('jenkins_jenkins') do
  it do 
    should exist
    should have_restart_policy('any') 
    should have_restart_limit(3) 
    should have_image('jenkins/jenkins:lts') 
    should have_user('jenkins') 
    should have_network('jenkins') 
    should_not be_global 
    should be_replicated 
    should have_replica_count 1 
    should have_placement_constraint 'node.role == manager' 
    should map_port('8080', '8080', 'tcp', 'ingress') 
    should have_host('169.254.1.1 leek') 
    should have_mount('/tmp', '/dir') 
  end
  # TODO: Label Matcher
end

