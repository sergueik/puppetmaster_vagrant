require 'spec_helper'

describe 'Operating system' do
  context 'family' do
    subject { os[:family] }
    # NOTE: for this expectation one needs a symbol, not a string
    it { is_expected_to eq 'alpine'  }
  end
  %w|build-base libcurl libxml2-dev libxslt-dev libffi-dev libmcrypt-dev openssl|.each do |package_name|
    describe package package_name do
      it { should be_installed }
    end
  end
  %w|jq xmllint|.each do |tool|
    describe command ("which #{tool}") do
      its(:stdout) { should_not be_empty }
    end
  end
  # TODO: generate sample files
  describe command "jq '.foo' '/serverspec/tmp/data.json'" do
    its(:stdout) { should contain 'bar' }
  end
  describe command "xmllint --xpath '/Server/@port' '/serverspec/tmp/data.xml'" do
    its(:stdout) { should contain 'port="8005"' }
  end

  describe file ('/usr/local/bin/ruby') do
    it { should be_file }
    it { should be_executable }
  end

  [
    'Rakefile',
    'spec/spec_helper.rb',
    'spec/docker_helper.rb',
  ].each do |filename|
    describe file "/serverspec/#{filename}" do
      it { should exist }
    end
  end
  [
    'rspec',
    'rspec_junit_formatter',
    'serverspec',
  ].each do | gem |
    describe package(gem) do
      it { should be_installed.by('gem') }
    end
  end
end

