#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'

opt = OptionParser.new

@options = {
  :warnings  => false,
  :directory => 'reports',
  :maxcount  => 0,
  :report    => 'report_.json',
}

opt.on('--directory', 'Path to the Report') do |val|
  @options[:directory] = val
end

opt.on('--report', 'Report name') do |val|
  @options[:report] = val
end

opt.on('--maxcount [RESOURCES]', Integer, 'Max number of errors to print before stopping evaluation') do |val|
  @options[:maxcount] = val
end

opt.on('--[no-]warnings', 'Extract Warnings') do |val|
  @options[:warnings] = val
end

opt.parse!
ignore_statuses =
if @options[:warnings] 
  'passed'
else
  '(?:passed|pending)'
end

report_path = "#{@options[:directory]}/#{@options[:report]}"
puts "Reading: '#{report_path}'"
report_obj = JSON.parse(File.read(report_path), symbolize_names: true)
count = 1

report_obj[:examples].each do |example|
  if example[:status] !~ Regexp.new(ignore_statuses,Regexp::IGNORECASE)
    pp [example[:status],example[:full_description]]
    count = count + 1
    break if @options[:maxcount] > 0 and count > @options[:maxcount]
  end
end
puts 'Summary:'
pp report_obj[:summary_line]
