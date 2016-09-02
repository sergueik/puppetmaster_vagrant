#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'

opt = OptionParser.new

@options = {
  :warnings  => false,
  :directory => 'results',
  :maxcount  => 0,
  :report    => 'result.json',
}

opt.on('--directory', 'Path to the Report') do |val|
  @options[:directory] = val
end

opt.on('--report', 'Report name') do |val|
  @options[:report] = val
end

opt.on('--serverspec', 'Path to serverspec') do |val|
  @options[:serverspec] = val
end

opt.on('--maxcount [RESOURCES]', Integer, 'Max number of errors to print before stopping evaluation') do |val|
  @options[:maxcount] = val
end

opt.on('--[no-]warnings', 'Extract the Warnings') do |val|
  @options[:warnings] = val
end

opt.parse!
ignore_statuses =
if @options[:warnings] 
  'passed'
else
  '(?:passed|pending)'
end

resultpath = "#{@options[:directory]}/#{@options[:report]}"
puts "Reading: '#{resultpath}'"
resultobj = JSON.parse(File.read(resultpath), symbolize_names: true)
count = 1

resultobj[:examples].each do |example|
  if example[:status] !~ Regexp.new(ignore_statuses,Regexp::IGNORECASE)
    pp [example[:status],example[:full_description]]
    count = count + 1
    break if @options[:maxcount] > 0 and count > @options[:maxcount]
  end
end
puts 'Summary:'
pp resultobj[:summary_line]
