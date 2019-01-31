#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'rest-client'
require 'sqlite3'

# https://www.sitepoint.com/guide-ruby-csv-library-part/

options = {
  :maxcount => 10,
  :name     => 'result_.json',
  :basedir  => nil,
  :debug    => false,
  :fulldump => false,
  :fullstore => false,
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

opt.on('-mMAXCOUNT', '--maxcount=MAXCOUNT', Integer, 'Max number of rows to process') do |val|
  options[:maxcount] = val
end

opt.on('-d' , '--[no-]debug', 'Log detailed info') do |val|
  options[:debug] = val
end

opt.on('-f' , '--[no-]fulldump', 'Dump zips csv to SQLite (time consuming)') do |val|
  options[:fulldump] = val
end

opt.on('-s' , '--[no-]fullstore', 'store updated zips from SQLite  back to csv (time consuming)') do |val|
  options[:fullstore] = val
end

opt.parse!
$DEBUG = false
if options[:debug]
  $DEBUG = options[:debug]	
end

$FULL_DUMP = false
if options[:fulldump]
  $FULL_DUMP = options[:fulldump]	
end

$MAXCOUNT = 10
if options[:maxcount]
  $MAXCOUNT = options[:maxcount]	
end

$FULL_STORE = false
if options[:fullstore]
  $FULL_STORE = options[:fullstore]	
end
# API: Multiple Zip Codes by Radius
# activated via visiting the link https://www.zipcodeapi.com/Activate/...
$BASE_URL_TEMPLATE = 'https://www.zipcodeapi.com/rest/<api_key>/info.<format>/<zip_code>/<distance>/<units>'

$BASE_URL_TEMPLATE = 'https://www.zipcodeapi.com/rest/<api_key>/multi-radius.<format>/<distance>/<units>'
# NOTE: POST, not GET

$API_KEY = 'XXXXXXXXxxxxXXXXXXXXXXXXXXXXXXXxXXXXxXXxXXXXXXXXXXxXXXXXxxxXXXXX'
unless options[:api_key].nil?
  $API_KEY = options[:api_key]
end

# https://rubyplus.com/articles/1141-SQL-Basics-SQLite3-Ruby-Driver-Basics
# https://www.rubydoc.info/github/sparklemotion/sqlite3-ruby/SQLite3/Database

database_filename = 'zipcodes.db'
if $DEBUG
  $stderr.puts ('Creating database schema to store data ' + database_filename )
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
  # TODO: find if schema is already made
  $stderr.puts ('Exception (ignored ) ' + ex.to_s)
end

if $DEBUG
  puts rows
  puts rows.inspect
end

basedir = ENV.fetch('HOME','') || ENV.fetch('USERPROFILE', '')

unless options[:basedir].nil?
  basedir = options[:basedir]
end
basedir = basedir.gsub('\\', '/')

if $FULL_DUMP
  # Full dump
  # NOTE: slow
  csv_file_path = "#{basedir}/Downloads/zip.csv"
  zips = CSV.read(csv_file_path )
  if $DEBUG
    $stderr.puts ('Full dump to the database:' + zips.size.to_i.to_s + ' rows into ' + database_filename)
  end
  SQLite3::Database.new( database_filename  ) do |db|
    zips.each do |row|
      query = "insert into zipcodes (primary_zipcode,neighbour_zipcodes) values  (\"#{row[0]}\" ,\"\")"
      if $DEBUG
        $stderr.puts ( 'Running query: ' + query)
      end
      db.execute(query)
      if $DEBUG
        pp row
      end
    end
  end
end
# subset
# NOTE: slow
csv_file_path = "#{basedir}/Downloads/zip_small.csv"
if $DEBUG
  $stderr.puts "Reading zips csv from \"#{csv_file_path}\""
end
zips = CSV.read(csv_file_path )
# NOTE: slow
zips.select { |item| item.length < 2 || item[1].nil? }.slice(0,$MAXCOUNT - 1).each do |row|
  if row.length < 2	
    row.push('*')
  else
    row[1] = '*'	
  end
  if $DEBUG
    pp row
  end
  zip_code = row[0]
  distance = 5
  inputs = {
    'api_key'  => $API_KEY,
    'units'    => 'miles', # 'km'
    'format'   => 'json',
    'distance' => distance,
    'zip_code' => zip_code
  }
  base_url = $BASE_URL_TEMPLATE
  inputs.each do |key,val|
    base_url.gsub!("<#{key}>", val.to_s)
  end
  postdata = {:zip_codes => zip_code}
  if $DEBUG
    $stderr.puts 'POST: ' + base_url
    pp  postdata
  end
  # https://github.com/rest-client/rest-client
  begin
    response = RestClient.post base_url, postdata

    $stderr.puts 'Processing response code'
    pp response.code
    # zip_codes: 79905
    # {base_zip_code: "79905", zip_codes: ["79905"]}
    # https://www.zipcodeapi.com/rest/PYqmVHQg0020RNQsQIFWqJHnNokGDuw0Efhs3wO3Frvcbuylam6BbBAB449POFPa/info.json/79925/10/miles?minimal
    # RestClient.get base_url
    if response.code != 400  && response.code != 401 && response.code != 404  && response.code != 429
      o = JSON.load(response.body)
    end
  rescue => ex
      o = nil
      $stderr.puts 'Processing exception'
      # pp response.code
      # rest_merge_csv.rb:187:in `rescue in block in <main>': undefined method `code' for nil:NilClass (NoMethodError)
      # C:/Ruby23-x64/lib/ruby/gems/2.3.0/gems/rest-client-2.0.2-x64-mingw32/lib/restclient/abstract_response.rb:223:in `exception_with_response': 400 Bad Request (RestClient::BadRequest)
  end
  unless o.nil?
    if $DEBUG
      $stderr.puts 'Raw response: '
      pp o
    end
    data = o['responses'][0]
    base_zip_code = data['base_zip_code']
    puts base_zip_code
    zip_codes = data['zip_codes']
    puts zip_codes
    row[1] = zip_codes.join(',')
    if $DEBUG
      pp row
    end
  end
end

CSV.open("#{basedir}/Downloads/zip_small.csv", 'w') do |o|
  zips.each do |row|
    o << row
  end
end
$stderr.puts ('Updating the database:' + zips.size.to_i.to_s + ' rows into ' + database_filename)
SQLite3::Database.new( database_filename )  do |db|
  zips.each do |row|
    query = "update zipcodes set neighbour_zipcodes = \"#{row[1]}\" where primary_zipcode = \"#{row[0]}\""
    # query = "insert into zipcodes (primary_zipcode,neighbour_zipcodes) values  (\"#{row[0]}\" ,\"#{row[1]}\")"
    if $DEBUG
      $stderr.puts ( 'Running query: ' + query)
    end
    db.execute(query)
  end
end
if $FULL_STORE
  result_filename = "#{basedir}/Downloads/zip_full.csv"
  result = []

  $stderr.puts ('Reading the data from ' + database_filename + ' backi into ' + result_filename)
  SQLite3::Database.new(database_filename ) do |db|
    db.execute( 'select primary_zipcode,neighbour_zipcodes from zipcodes' ) do |row|
      result_row = []
      result_row[0] = row[0]
      result_row[1] = row[1]
      result.push result_row
    end
  end
  cnt = 0
  CSV.open(result_filename, 'w') do |o|
    result.each do |row|
      if $DEBUG
        $stderr.puts ( 'Updating row: ' + cnt.to_s)
        pp row
      end
      cnt = cnt + 1
      o << row
    end
  end
end
exit
