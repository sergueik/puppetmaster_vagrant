require 'spec_helper'

context 'Process Puppet Agent Logs' do

  context 'Summary' do 
    # TODO: ismx
    lines = [ 
      'failed: 0',
    ]
    ruby_script = <<-EOF
  require 'yaml'
  require 'pp'
   
  # Read Puppet Agent last run summary
  
  puppet_last_run_summary = \\`puppet config print 'lastrunfile'\\`.chomp
  data = File.read(puppet_last_run_summary)
  # Parse
  puppet_summary = YAML.load(data)
  puts \\"Summary\\nResources\\n\\" + puppet_summary['resources'].to_yaml
  EOF
    describe command("ruby -e \"#{ruby_script}\"") do
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end 

  context 'State' do 
    # TODO: ismx
    lines = [ 
      'Class[Main]',
    ]
    ruby_script = <<-EOF
  require 'yaml'
  require 'pp'
  
  # Read Puppet Agent last run state
  # NOTE: escaping special characters to prevent execution by shell
  puppet_statefile = \\`puppet config print 'statefile'\\`.chomp
  data = File.read(puppet_statefile)
  # Extract Resources
  puppet_state = YAML.load(data)
  puts puppet_state.keys.to_yaml  
  EOF
    describe command("ruby -e \"#{ruby_script}\"") do
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end 
end

