#! /usr/bin/env ruby

require 'csv'
require 'pp'
require 'yaml'
require 'json'
require 'optparse'

@options = {
  :debug => false,
  :node  => 'discovery',
  :env   => 'test',
  :dc    => 'west',
}

# vagrant@localhost:/vagrant$ echo server bcp north |./loader_skeleton.rb
# {:debug=>false, :node=>"server", :env=>"bcp", :dc=>"north"}

# only works right in Linux environment 
unless (/cygwin|mswin|mingw/ =~ RUBY_PLATFORM) != nil
  # determine input is coming from the pipe
  unless $stdin.tty?
    # $stderr.puts 'Processing STDIN' 
    positional  = %w|node env dc|
    ARGF.each do |line|
      line.split(/\s+/).each_with_index do |token, index|
        @options[positional[index].to_sym] = token
      end
    end
    pp @options
    exit
  end
end
o = OptionParser.new

# ./loader_skeleton.rb --node server --dc east --env uat{:debug=>false, :node=>"server", :env=>"uat", :dc=>"east"}

o.on('--node [NODE]', 'role of the node') do |val|
  @options[:node] = val
end

o.on('--dc [DC]', 'cluster data center') do |val|
  @options[:dc] = val
end

o.on('--env [ENV]', 'cluster environment') do |val|
  @options[:env] = val
end

o.on('--debug', 'Debug') do |val|
  @options[:debug] = val
end

o.parse!
pp @options
