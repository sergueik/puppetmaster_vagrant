require 'serverspec'

set :backend, :cmd

RSpec.configure do |config|
  config.filter_gems_from_backtrace 'vagrant', 'vagrant-serverspec'
end
