require 'yaml'
require 'json'
require 'csv'

if => ENV.has_key?('URU_INVOKER')
  if File.exists?( 'spec/windows_spec_helper.rb')
    require_relative '../windows_spec_helper'
  end
else  
  require_relative '../windows_spec_helper'
end

context 'basic' do
  variable = 5
  it { expect(variable).to be 5  }
  it { expect(variable>3).to be true }    
end

# This example inspects the Puppet Last Run report on the instance
# through uru (really possible in other ways, WIP)
context 'Puppet Last Run Report Test' do
  # NOTE:  relies on the following DOM fragment
  # "resources"  => {
  #   "changed" => 6, 
  #   "failed" => 0, 
  #   "failed_to_restart" => 0, 
  #   "out_of_sync" => 6, 
  #   "restarted" => 1, 
  #   "scheduled" => 0, 
  #   "skipped" => 0, 
  #   "total" => 10
  #   }, 
  #   ...
  # NOTE: PATH separators are slant-sensitive, the following will not work
  state_path = 'C:/programdata/PuppetLabs/puppet/cache/state'
  reports_path = 'c:/ProgramData/PuppetLabs/puppet/cache/reports' 
  # NOTE: the following will do:
  state_path = 'C:\programdata\PuppetLabs\puppet\cache\state'
  reports_path = 'c:\ProgramData\PuppetLabs\puppet\cache\reports' 
  
  # NOTE: there is one more directory with historic reports

  state_yaml = 'state.yaml'
  last_run_summary_yaml = 'last_run_summary.yaml'
  describe 'Last run',  :if => File.exist?(state_path) do
    last_run_summary_yaml_path = File.join(state_path , last_run_summary_yaml)
    if File.exist?(last_run_summary_yaml_path) 
      STDERR.puts 'Reading file: ' + last_run_summary_yaml_path
      parameters = YAML.load_file(last_run_summary_yaml_path)
      resources = parameters['resources']
      %w|
        failed
        restarted
        changed
        out_of_sync
      |.each do |k|
        STDERR.puts  k + ': ' + resources[k].to_s
      end
      it { should contain 'Last run' } 
      it { expect(resources['failed']).to be 0 }
      it { expect(resources['failed']>0).to be false }    
    else
      STDERR.puts last_run_summary_yaml_path + ' does not exist'
    end
  end
end
