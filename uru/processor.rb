#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'


options = {
  :maxcount   => 100,
  :name       => 'result.json',
  :directory  => 'results',
  :serverspec => 'spec/local',
  :warnings   => false,
}

opt = OptionParser.new

opt.on('-dDIRECTORY', '--directory=DIRECTORY', 'Path to the results') do |val|
  options[:directory] = val
end

opt.on('-nNAME', '--name=NAME', 'Result report name') do |val|
  options[:name] = val
end

opt.on('-sSERVERSPEC', '--serverspec=SERVERSPEC', 'Path to serverspec') do |val|
  options[:serverspec] = val
end

opt.on('mMAXCOUNT', '--maxcount=MAXCOUNT', Integer, 'Max number of errors to print before stopping evaluation') do |val|
  options[:maxcount] = val
end

opt.on('-w' , '--[no-]warnings', 'Extract the Warnings') do |val|
  options[:warnings] = val
end

opt.parse!
ignore_statuses =
if options[:warnings]
  'passed'
else
  '(?:passed|pending)'
end

results_path = "#{options[:directory]}/#{options[:name]}"
puts 'Reading: ' + results_path
results_obj = JSON.parse(File.read(results_path), symbolize_names: true)
count = 1

results_obj[:examples].each do |example|
  if example[:status] !~ Regexp.new(ignore_statuses,Regexp::IGNORECASE)
    full_description = example[:full_description]
    if full_description =~ /\n/
      short_description = (full_description.split(/\r?\n/).grep(/\S/))[0..1].join(' ')
    else
      short_description = full_description
    end
    pp [example[:status],short_description]
    count = count + 1
    break if options[:maxcount] > 0 and count > options[:maxcount]
  end
end
# compute stats -
# NOTE: there is no outer context information in the `result.json`
stats = {}
results_obj[:examples].each do |example|
  spec_path = example[:file_path]
  unless stats.has_key?(spec_path)
    stats[spec_path] = { :passed => 0, :failed => 0, :pending => 0 }
  end
  stats[spec_path][example[:status].to_sym] = stats[spec_path][example[:status].to_sym] + 1
end
puts 'Stats:'
stats.each do |spec_path,number_examples|
  context = File.read(spec_path).scan(/context ['"].+['"] do\s*$/).first.gsub(/^\s*context\s+['"](.+)['"]\s+do\s*$/, '\1')
  # not counting pending examples 
  puts spec_path.gsub(/^.+\//,'') + "\t" + (100.00 * number_examples[:passed] / (number_examples[:passed] + number_examples[:failed])).round(2).to_s + "%\t" + context
end
puts 'Summary:'
puts results_obj[:summary_line]
