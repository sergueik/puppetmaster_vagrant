#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'rest-client'
require 'sqlite3'
# require 'sqlite3-ruby'
# C:/Ruby23-x64/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# : cannot load such file -- sqlite3-ruby (LoadError)
# sqlite3 -version
# 3.11.1 2016-03-03 16:17:53 f047920ce16971e573bc6ec9a48b118c9de2b3a7
# gem install --no-ri --no-rdoc sqlite3 sqlite3-ruby
# Successfully installed sqlite3-1.3.13-x64-mingw32

# https://www.sitepoint.com/guide-ruby-csv-library-part/

options = {
  :maxcount   => 10,
  :name       => 'result_.json',
  :basedir    => nil,
  :debug      => false,
}

opt = OptionParser.new
opt.on('-bDIRECTORY', '--basedir=DIRECTORY', 'Path to the results') do |val|
  options[:basedir] = val
end

opt.on('-nNAME', '--name=NAME', 'csv file name (unused)') do |val|
  options[:name] = val
end

opt.on('-aAPI_KEY', '--api_key=API_KEY', ' api_key') do |val|
  options[:api_key] = val
end

opt.on('-mMAXCOUNT', '--maxcount=MAXCOUNT', Integer, 'Max number of runs (unusedi)') do |val|
  options[:maxcount] = val
end

opt.on('-d' , '--[no-]debug', 'Extract the Warnings') do |val|
  options[:debug] = val
end

opt.parse!
$DEBUG = false
if options[:debug]
  $DEBUG = options[:debug]	
end

# https://rubyplus.com/articles/1141-SQL-Basics-SQLite3-Ruby-Driver-Basics
# https://www.rubydoc.info/github/sparklemotion/sqlite3-ruby/SQLite3/Database
database_filename = 'zipcodes.db'
if $DEBUG
  $stderr.puts ("Creating schema to store data in the database " + database_filename )
end
db = SQLite3::Database.new(database_filename)
begin
rows = db.execute <<-SQL
  create table zipcodes(
    primary_zipcode varchar (20),
    neighbour_zipcodes varchar(120)
  );
SQL
rescue => ex
 $stderr.puts ("Exception (ignored ) " + ex.to_s)
end
if $DEBUG
  puts rows
  puts rows.inspect
end
basedir = ENV.fetch('HOME','') || ENV.fetch('USERPROFILE', '')
box_memory = ENV.fetch('BOX_MEMORY', '2048').to_i

unless options[:basedir].nil?
  basedir = options[:basedir]
end
basedir = basedir.gsub('\\', '/')
# NOTE: slow
csv_file_path ="#{basedir}/Downloads/zip_small.csv"
if $DEBUG
  $stderr.puts "Reading zips csv from \"#{csv_file_path}\""
end
zips = CSV.read(csv_file_path )
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
$stderr.puts ('Storing in the database:' + zips.size.to_i.to_s + ' rows into ' +  database_filename)
SQLite3::Database.new( database_filename  ) do |db|
  zips.each do |row|
    query = "insert into zipcodes (primary_zipcode,neighbour_zipcodes) values  (\"#{row[0]}\" ,\"#{row[1]}\")"
    if $DEBUG
      $stderr.puts ( 'Running query: ' + query)
    end
    db.execute(query)
  end
end
$stderr.puts ('Reading the data from ' + database_filename )
SQLite3::Database.new(database_filename ) do |db|
  db.execute( 'select * from zipcodes' ) do |row|
    pp row
  end
end
exit
