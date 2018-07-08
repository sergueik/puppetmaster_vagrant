# based on: https://github.com/inspec/inspec/blob/master/lib/bundles/inspec-compliance/http.rb

require 'net/http'
require 'uri'
require 'pp'

module Serverspec::Type

  # implements a simple http abstraction on top of Net::HTTP
  class HTTP
    attr_accessor :url
    attr_accessor :host
    def initialize(host)
      @host = host
    end
    def retries(max_retries)
      options[:retry] = max_retries
    end

    def handling?(url = nil, method = 'GET', retries = 0, headers = nil)
      begin
        $stderr.puts "url = " + url
        $stderr.puts "method = " + method 
        $stderr.puts "headers = " + headers
      rescue => e
      end
      @url = url
      $stderr.puts "url = " + @url
      uri = parse_url(@host + '/' + @url)
      pp uri
      $stderr.puts "uri.path = " + uri.path
      req = Net::HTTP::Get.new(uri)
      send_request(uri, req)
    end

    # sends a http requests
    def send_request(uri, req, insecure = false)
      opts = {
        use_ssl: uri.scheme == 'https',
      }
      opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if insecure

      raise "Unable to parse URI: #{uri}" if uri.nil? || uri.host.nil?
      res = Net::HTTP.start(uri.host, uri.port, opts) { |http|
        http.request(req)
      }
      res
    rescue OpenSSL::SSL::SSLError => e
      raise e unless e.message.include? 'certificate verify failed'

      puts "Error: Failed to connect to #{uri}."
      puts 'If the server uses a self-signed certificate, please re-run the login command with the --insecure option.'
      exit 1
    end

    def parse_url(url)
      url = "https://#{url}" if URI.parse(url).scheme.nil?
      URI.parse(url)
    end
  end
  def http(host)
    HTTP.new(host)
  end

end

include Serverspec::Type

RSpec::Matchers.define :be_handling do
  match do |http|
    http.handling? @url, @method, @retries
  end

  chain :with_url do |url|
    @url = url
  end


  chain :with_method do |method|
    @method = method
  end

  chain :with_retry do |retries|
    @retries = retries
  end

  chain :with_delay do |delay|
    @delay = delay
  end
end

