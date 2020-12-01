#! /usr/bin/env ruby

require 'csv'
require 'pp'
require 'yaml'
require 'json'
require 'optparse'

@options = {
  :debug => false,
  :validate => false,
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
    if  val =~ /^@/
      # e.g. echo bill > ms.txt
      # e.g. echo steve,satya >> ms.txt
      # ruby loader_skeleton.rb -d --role @ms.txt
      # { :debug => true,
      #   :role => 'bill,steve,satya'
      #   ...
      # e.g. echo -e "bill\n   steve\n\n#satya" > ms.txt
      # ruby loader_skeleton.rb -d --role @ms.txt
      # { :debug => true,
      #   :role => 'bill,steve'
      #   ...
      begin
        # NOTE: dot count sensitive
        arg_file = val[1..-1]
        file = File.open(arg_file)
        # blank lines, leading and railing whitespace
        data = file.readlines.map(&:chomp).reject { |row| row.empty? }.map(&:strip).reject do
			|row| row =~ /^#/
        end
        # NOTE: cannot reject  do ... end and then map
        # will later @options[:role].split( /,/)
  	    @options[:role] = data.join(',')
      rescue => e
        puts ('Exception: ' + e.to_s)
      end  
    else
	  @options[:role] = val
    end
  end

  o.on('--dc [DC]', 'cluster data center') do |val|
    @options[:dc] = val
  end

  o.on('--env [ENV]', 'cluster environment') do |val|
    val = 'exact-value' if val == 'alias' # for values that need alias
    @options[:env] = val
  end

  o.on('-d', '--debug', 'Debug') do |val|
    @options[:debug] = val
  end
  # https://stackoverflow.com/questions/54576873/ruby-optionparser-short-code-for-boolean-option
  # -validate no
  # -validate false
  # --no-validate
  # => @options[:validate] is false
  # --validate yes
  # --validate true
  # --validate
  # => @options[:validate] is true
  o.on('-v', '--[no-]validate [FLAG]', TrueClass, 'Run validations') do |val|
    @options[:validate] = val.nil? ? true : val
  end

  o.parse!
end
pp @options
