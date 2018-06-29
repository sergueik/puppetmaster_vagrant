require 'spec_helper'

context 'Development Emvironment Check' do

  # one can easily check for Vagrant environment
  is_vagrant = ENV.has_key?('VAGRANT_EXECUTABLE')
  if is_vagrant
    fact_name = 'is_development_environment'
    # othen the bootstrap script adds certain facts to manifest development environment to Puppet
    # the below expectation does the same to allow on verify actions which are not safe in UAT and PROD
    is_development_environment = command("/opt/puppetlbs/bin/facter -p '#{fact_name}'").stdout.chomp
    describe is_development_environment do, :if => ENV.has_key?('VAGRANT_EXECUTABLE') do
      it { should be_truthy }
      it { should match /true/ }
    end
    if is_development_environment
      # perform PROD unsafe testing
    end
  end
end
