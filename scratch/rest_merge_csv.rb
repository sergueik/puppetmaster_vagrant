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

# loading cmdline parameters

opt.on('-bDIRECTORY', '--basedir=DIRECTORY', 'Path to the csv files') do |val|
  options[:basedir] = val
end

opt.on('-nNAME', '--name=NAME', 'csv file name (unused)') do |val|
  options[:name] = val
end

opt.on('-aAPI_KEY', '--api_key=API_KEY', ' api_key') do |val|
  options[:api_key] = val
end

opt.on('-mMAXCOUNT', '--maxcount=MAXCOUNT', Integer, 'Max number of rows to process in one batch') do |val|
  options[:maxcount] = val
end

opt.on('-d' , '--[no-]debug', 'Log detailed info') do |val|
  options[:debug] = val
end

opt.on('-f' , '--[no-]fulldump', 'Initial dump of zips csv to SQLite (time consuming)') do |val|
  options[:fulldump] = val
end

opt.on('-s' , '--[no-]fullstore', 'Store updated zips from SQLite back into csv (time consuming)') do |val|
  options[:fullstore] = val
end

opt.parse!

# use class wide constants for visibility

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
$BASE_URL_TEMPLATE = 'https://www.zipcodeapi.com/rest/<api_key>/multi-radius.<format>/<distance>/<units>'

$API_KEY = 'XXXXXXXXxxxxXXXXXXXXXXXXXXXXXXXxXXXXxXXxXXXXXXXXXXxXXXXXxxxXXXXX'
unless options[:api_key].nil?
  $API_KEY = options[:api_key]
end

# NOTE: database will be created in the current directory
database_filename = 'zipcodes.db'

basedir = ENV.fetch('HOME','') || ENV.fetch('USERPROFILE', '')

unless options[:basedir].nil?
  basedir = options[:basedir]
end
basedir = basedir.gsub('\\', '/')

# https://rubyplus.com/articles/1141-SQL-Basics-SQLite3-Ruby-Driver-Basics
# https://www.rubydoc.info/github/sparklemotion/sqlite3-ruby/SQLite3/Database

if $FULL_DUMP

  if $DEBUG
    puts ('Initialize SQL database schema in ' + database_filename )
  end
  db = SQLite3::Database.new(database_filename)
  begin
    rows = db.execute <<-EOF
      create table zipcodes(
        primary_zipcode varchar (20),
        neighbour_zipcodes varchar(120)
      );
    EOF

    if $DEBUG
      unless rows.nil?
        puts rows
      end
    end
  rescue => ex
    # TODO: find if schema is already made
    puts ('Exception from initialize SQL database schema (ignored): ' + ex.message)
  end
  # Perform Full dump
  # NOTE: slow
  csv_file_path = "#{basedir}/Downloads/zip.csv"
  zips = CSV.read(csv_file_path )
  if $DEBUG
    puts ('Full dump to the database:'+ database_filename +  ' Written'  + zips.size.to_i.to_s + ' rows ' )
  end
  cnt = 0
  SQLite3::Database.new( database_filename  ) do |db|
    zips.each do |row|
      query = "insert into zipcodes (primary_zipcode,neighbour_zipcodes) values  (\"#{row[0]}\" ,\"\")"
      if $DEBUG
        if cnt < 3
          puts 'Inserting row:'
          pp row
          puts ( 'Running query: ' + query)
        end
        cnt =  cnt + 1
      end
      db.execute(query)
    end
  end
end
$USE_SQLITE_DURING_RUN = true
if $USE_SQLITE_DURING_RUN
  puts ('Reading data from SQLite database ' + database_filename)
  zips = []
  SQLite3::Database.new( database_filename  ) do |db|
    # SQL expectss single quotes as string delimeters
    query = "select distinct(primary_zipcode) from zipcodes where neighbour_zipcodes is null  or neighbour_zipcodes =  ''"
    rows = db.execute(query)
    rows.each do |row|
      # if $DEBUG
      #   puts 'query result: '
      #   pp row
      # end
      zips_row = []
      zips_row[0] = row[0]
      zips_row[1] = nil
      zips.push zips_row
    end
  end
else
  # subset
  # NOTE: slow
  csv_file_path = "#{basedir}/Downloads/zip_small.csv"
  if $DEBUG
    puts "Reading zips csv from \"#{csv_file_path}\""
  end
  zips = CSV.read(csv_file_path )
end
puts ('Loaded ' + zips.size.to_s + ' rows')

distance = 5
inputs = {
  'api_key'  => $API_KEY,
  'units'    => 'miles', # 'km'
  'format'   => 'json',
  'distance' => distance,
}
base_url = $BASE_URL_TEMPLATE
inputs.each do |key,val|
  base_url.gsub!("<#{key}>", val.to_s)
end

puts ('Processing ' + $MAXCOUNT.to_s + ' rows')
zips.select { |item| item.length < 2 || item[1].nil? }.slice(0,$MAXCOUNT - 1).each do |row|
  if row.length < 2	
    row.push('*')
  else
    row[1] = '*'	
  end
  if $DEBUG
    puts 'Filling missing data for row: '
    pp row
  end
  zip_code = row[0]
  postdata = {:zip_codes => zip_code}
  if $DEBUG
    puts 'POST: ' + base_url
    # NOTE: POST, not GET
    pp postdata
  end
  # https://github.com/rest-client/rest-client
  begin
    response = RestClient.post base_url, postdata
    if $DEBUG
      puts ('Processing response code ' + response.code.to_s )
    end
    if response.code != 400  && response.code != 401 && response.code != 404  && response.code != 429
      o = JSON.load(response.body)
    end
  rescue => ex
    o = nil
    puts 'Ignoring RestClient exception: ' + ex.message
    # Exception `RestClient::TooManyRequests'
    # 400 Bad Request for e.g. zipcode: '33755-6314'
    if ex.message =~ /429/
      # mark ok to retry 
      row[1] = ''
    end
  end
  unless o.nil?
    if $DEBUG
      puts 'Raw response: '
      pp o
    end
    data = o['responses'][0]
    base_zip_code = data['base_zip_code']
    puts base_zip_code
    zip_codes = data['zip_codes']
    puts zip_codes
    row[1] = zip_codes.join(',')
   # if $DEBUG
   #   pp row
   # end
  end
end
if !$USE_SQLITE_DURING_RUN
  csv_filepath =  "#{basedir}/Downloads/zip_small.csv"
  puts ('Updating the csv: '  + csv_filepath + ' with some of ' + zips.size.to_i.to_s + ' rows')
  CSV.open(csv_filepath, 'w') do |o|
    zips.each do |row|
      o << row
    end
  end
end

puts ('Updating the database:' + zips.size.to_i.to_s + ' rows into ' + database_filename)
cnt = 0
SQLite3::Database.new( database_filename )  do |db|
  puts ('Actually Updating the database:' + database_filename)
  zips.each do |row|
  #  if row[1] =~ /\S/ 
      query = "update zipcodes set neighbour_zipcodes = \"#{row[1]}\" where primary_zipcode = \"#{row[0]}\""
      if $DEBUG
        if cnt < 4
          puts 'Saving row:'
          pp row
          puts ( 'Running query: ' + query)
          cnt = cnt + 1 
        end
      end
      db.execute(query)
   # end
  end
end
if $FULL_STORE
  result_filename = "#{basedir}/Downloads/zip_full.csv"
  result = []
  puts ('Reading the data from ' + database_filename + ' backi into ' + result_filename)
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
        puts ( 'Updating row: ' + cnt.to_s)
        pp row
      end
      cnt = cnt + 1
      o << row
    end
  end
end
if $DEBUG
  puts 'Counting finished rows: '
  result = 0
  SQLite3::Database.new( database_filename  ) do |db|
    zips.each do |row|
      query = "select count(primary_zipcode) from zipcodes where neighbour_zipcodes not null and neighbour_zipcodes <> ''"
      result = db.execute(query)
    end
  end
  puts ('Total rows ' + result.to_s)
end

exit
