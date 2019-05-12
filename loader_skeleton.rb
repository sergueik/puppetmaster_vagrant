#! /usr/bin/env ruby

require 'csv'
require 'pp'
require 'yaml'
require 'json'
require 'optparse'

@options = {
  :debug => false,
  :role  => 'app-worker',
  :env   => 'test',
  :dc    => 'west',
}
options_defined = false
# find -type f -name "*.fb2" | sort | xargs -n1 ruby loader_skeleton.rb
# echo application-server bcp north |./loader_skeleton.rb
# {:debug => false, :role => "application-server", :env => "bcp", :dc => "north"}

# $stdin.tty? does not appear to work right under Windows environment
# https://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
unless (/cygwin|mswin|mingw/ =~ RUBY_PLATFORM) != nil
  # determine input is coming from the pipeline
  unless $stdin.tty?
    # based on:
    # https://www.ruby-forum.com/t/how-to-determine-if-pipe-is-given/70241/4
    # $stderr.puts 'Processing STDIN'
    positional  = %w|role env dc debug|
    ARGF.each do |line|
      line.split(/\s+/).each_with_index do |token, index|
	token = 'exact-value' if token == 'alias' # for values that need alias
        @options[positional[index].to_sym] = token
      end
    end
    options_defined = true
    # exit
  end
end
unless options_defined
  o = OptionParser.new

  # ./loader_skeleton.rb --role application-server --dc east --env uat
  # {:debug=>false, :role=>"application-server", :env=>"uat", :dc=>"east"}

  o.on('--role [NODE ROLE]', 'role of the node') do |val|
    @options[:role] = val
  end

  o.on('--dc [DC]', 'cluster data center') do |val|
    @options[:dc] = val
  end

  o.on('--env [ENV]', 'cluster environment') do |val|
    val = 'exact-value' if val == 'alias' # for values that need alias
    @options[:env] = val
  end

  o.on('--debug', 'Debug') do |val|
    @options[:debug] = val
  end

  o.parse!
end
pp @options
