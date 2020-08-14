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
  %w|jq xmllint python3|.each do |tool|
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
  context 'Python'do
    describe file ('/usr/bin/python3') do
      it { should be_file }
      it { should be_executable }
    end
    # origin: https://stackoverflow.com/questions/5389507/iterating-over-every-two-elements-in-a-list
    # see also https://www.geeksforgeeks.org/python-pair-iteration-in-list/
    # text = 'a1,b1,a2,b2,a3,b3,a4,b4,a5,b5'
    # data = text.split(',')
    # for k,v in zip(data[0::2], data[1::2]):
    #   print( '{} {}'.format(k,v))
    describe command( <<-EOF
      python3 -c "exec(\\\"\\\"\\\"\\\\ndata = 'a1,b1,a2,b2,a3,b3,a4,b4,a5,b5'.split(',')\\\\nfor k,v in zip(data[0::2], data[1::2]):\\\\n  print( '{}={}'.format(k,v))\\\\n\\\"\\\"\\\")"
    EOF
    ) do
      {
        'a1' => 'b1',
        'a2' => 'b2',
        'a3' => 'b3',
      }.each do |k,v|
        its(:stdout) { should contain "#{k}=#{v}" }
      end  
    end
  end
end
