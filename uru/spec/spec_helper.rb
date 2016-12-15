require 'serverspec'

set :backend, :exec

RSpec.configure do |config|
  config.filter_gems_from_backtrace 'vagrant', 'vagrant-serverspec'
end