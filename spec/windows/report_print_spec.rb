# https://raw.githubusercontent.com/ripienaar/puppet-reportprint/master/report_print.rb
# the repository consists of a single file
# that can be included inline 
# this is done in this spec.

require_relative '../windows_spec_helper'
context 'Execute embedded Ruby from Puppet Agent' do
  context 'With Environment' do
    # TODO: http://www.rake.build/fascicles/003-clean-environment.html
    lines = [ 
      'answer: 42',
      'status: changed'
    ]
    
    puppet_home_folder = 'Puppet Enterprise' # varies between PE  and Puppet community 
    puppet_home = 'C:/Program Files (x86)/Puppet Labs/' + puppet_home_folder
    puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
    last_run_report = "#{puppet_statedir}/last_run_report.yaml"
    rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
    rubyopt = 'rubygems' 
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-'EOF'
$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/facter/lib')
$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/hiera/lib')
$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/puppet/lib')

require 'yaml'
require 'puppet'
require 'pp'
require 'optparse'

class ::Numeric
  def bytes_to_human
    # Prevent nonsense values being returned for fractions
    if self >= 1
      units = ['B', 'KB', 'MB' ,'GB' ,'TB']
      e = (Math.log(self)/Math.log(1024)).floor
      # Cap at TB
      e = 4 if e > 4
      s = "%.2f " % (to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    else
      "0 B"
    end
  end
end



def load_report(path)
  YAML.load_file(path)
end

def report_resources(report)
  report.resource_statuses
end

def resource_with_evaluation_time(report)
  report_resources(report).select{|r_name, r| !r.evaluation_time.nil? }
end

def resource_by_eval_time(report)
  report_resources(report).reject{|r_name, r| r.evaluation_time.nil? }.sort_by{|r_name, r| r.evaluation_time rescue 0}
end

def resources_of_type(report, type)
  report_resources(report).select{|r_name, r| r.resource_type == type}
end


def print_report_summary(report)
# TODO : escaping
  puts "Report for " + report.host +  " in environment " + report.environment
end


def initialize_puppet
  require 'puppet/util/run_mode'
  Puppet.settings.preferred_run_mode = :agent
  Puppet.settings.initialize_global_settings([])
  Puppet.settings.initialize_app_defaults(Puppet::Settings.app_defaults_for_run_mode(Puppet.run_mode))
end

initialize_puppet

opt = OptionParser.new

@options = {
  :logs      => false,
  :motd      => false,
  :motd_path => '/etc/motd',
  :count     => 20,
  :report    => Puppet[:lastrunreport],
  :color     => STDOUT.tty?}

opt.on("--logs", "Show logs") do |val|
  @options[:logs] = val
end

opt.on("--motd", "Produce an output suitable for MOTD") do |val|
  @options[:motd] = val
end

opt.on("--motd-path [PATH]", "Path to the MOTD file to overwrite with the --motd option") do |val|
  @options[:motd_path] = val
end

opt.on("--count [RESOURCES]", Integer, "Number of resources to show evaluation times for") do |val|
  @options[:count] = val
end

opt.on("--report [REPORT]", "Path to the Puppet last run report") do |val|
  abort("Could not find report %s" % val) unless File.readable?(val)
  @options[:report] = val
end

opt.on("--[no-]color", "Colorize the report") do |val|
  @options[:color] = val
end

opt.parse!

report = load_report(@options[:report])

if @options[:motd]
  print_report_motd(report, @options[:motd_path])
else
  print_report_summary(report)
#  print_report_metrics(report)
#  print_summary_by_type(report)
#  print_slow_resources(report, @options[:count])
# print_files(report, @options[:count])
# print_summary_by_containment_path(report, @options[:count])
# print_logs(report) if @options[:logs]
end
 
EOF
 
  Specinfra::Runner::run_command(<<-END_COMMAND
  $script_file = '#{script_file}'
  @'
#{ruby_script}
'@ | out-file $script_file -encoding ascii
  
  END_COMMAND
  )
  
  
  describe command(<<-EOF
  $env:RUBYLIB="#{rubylib}"
  $env:RUBYOPT="#{rubyopt}"
  iex "ruby.exe '#{script_file}' '--report' #{last_run_report}"
  EOF
  ) do
      let(:path) { 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/sys/ruby/bin' }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end
