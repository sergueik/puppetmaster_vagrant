#
# TODO:  modify environment to ensure the path to the lib is passed to rspec
# e.g.
# c:/Ruby21-x64/bin/ruby.exe -I'c:/Ruby21-x64/lib/ruby/gems/2.1.0/gems/rspec-support-3.4.1/lib';'c:/Ruby21-x64/lib/ruby/gems/2.1.0/gems/rspec-core-3.4.3/lib';'c:/Vagrant/spec/type/lib' 'c:/Ruby21-x64/lib/ruby/gems/2.1.0/gems/rspec-core-3.4.3/exe/rspec' --pattern 'spec/windows/*_spec.rb'


require 'serverspec'
require 'serverspec_plus'

set :backend, :exec

describe event_log do
  it { should have_configuration('service/imap-login/inet_listener/imap/port').with_value(0) }
end