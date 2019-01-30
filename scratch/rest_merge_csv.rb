#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'rest-client'

# https://www.sitepoint.com/guide-ruby-csv-library-part/

options = {
  :maxcount   => 10,
  :name       => 'result_.json',
  :name       => 'result_.json',
  :basedir    => nil,
  :debug   => false,
}

opt = OptionParser.new
opt.on('-dDIRECTORY', '--basedir=DIRECTORY', 'Path to the results') do |val|
  options[:basedir] = val
end

opt.on('-nNAME', '--name=NAME', 'csv file name (unused)') do |val|
  options[:name] = val
end

opt.on('-nAPI_KEY', '--api_key=API_KEY', ' api_key') do |val|
  options[:api_key] = val
end

opt.on('mMAXCOUNT', '--maxcount=MAXCOUNT', Integer, 'Max number of runs (unusedi)') do |val|
  options[:maxcount] = val
end

opt.on('-w' , '--[no-]debug', 'Extract the Warnings') do |val|
  options[:debug] = val
end

opt.parse!
$DEBUG = false
if options[:debug]
  $DEBUG = options[:debug]	
end

basedir = ENV.fetch('HOME','') || ENV.fetch('USERPROFILE', '')
box_memory = ENV.fetch('BOX_MEMORY', '2048').to_i

unless options[:basedir].nil?
  basedir = options[:basedir]
end
basedir = basedir.gsub('\\', '/')
# NOTE: slow
zips = CSV.read("#{basedir}/Downloads/zip_small.csv")
# NOTE: slow
zips.select { |item| item.length < 2 || item[1].nil? }.slice(1,6).each do |row|
  if row.length < 2	
    row.push('*')
  else
    row[1] = '*'	
  end
  pp row
  base_url_template = 'https://www.zipcodeapi.com/rest/<api_key>/info.<format>/<zip_code>/<distance>/<units>'
  zip_code = row[0]
  distance = 5
  api_key = 'XXXXXXXXxxxxXXXXXXXXXXXXXXXXXXXxXXXXxXXxXXXXXXXXXXxXXXXXxxxXXXXX'
  unless options[:api_key].nil?
    api_key = options[:api_key]
  end
  # activated via visiting the link https://www.zipcodeapi.com/Activate/...
  inputs = {
    'api_key'  => api_key,
    'units'    => 'miles', # 'km'
    'format'   => 'json',
    'distance' => distance,
    'zip_code' => zip_code
  }
  base_url = base_url_template
  inputs.each do |key,val|
    base_url.gsub!("<#{key}>", val.to_s)
  end
  if $DEBUG
    $stderr.puts 'GET ' + base_url
  end
  response = RestClient.get base_url, {:params => {:minimal => nil}}
  # https://www.zipcodeapi.com/rest/PYqmVHQg0020RNQsQIFWqJHnNokGDuw0Efhs3wO3Frvcbuylam6BbBAB449POFPa/info.json/79925/10/miles?minimal
  # RestClient.get base_url
  if response.code != 400  && response.code != 401 && response.code != 404  && response.code != 429
    o = JSON.load(response.body)
    if $DEBUG
      pp o
    end
    data = o['zip_code']
    puts data
  end
  row[1] = data

  pp row
end
CSV.open("#{basedir}/Downloads/zip_small.csv", 'w') do |o|
  zips.each do |row|
    o << row
  end
end
exit
