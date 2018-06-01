require 'spec_helper'

# validate that the fixes made by profile to Splunk configuration files are observed
context 'Spulnk Configuration Files' do

  config_dir = '/opt/splunk/etc/system/local'
  hostname = %x|hostname --fqdn|.chomp

  # NOTE  the placement of commas

  {
    'server.conf' => <<-DATA,

      [general]
      servername = #{hostname}
      slaves = *
      [lmpool:auto_generated_pool_free]

    DATA
    'inputs.conf' => <<-DATA

      [default]
      host = #{hostname}

    DATA
  }.each do  |config, contents|
    describe file("#{config_dir}/#{config}") do
      it { should be_file }
      contents.split(/\r?\n/).grep(/\S/).each do |line|
        # it {should contain Regexp.escape(line.gsub(/^ +/,'').gsub(/ +$/,'')))}
        it {should contain Regexp.escape(line.strip)}
      end	
    end	
  end
end
