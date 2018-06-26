# based on: https://github.com/jantman/serverspec-extended-types/blob/master/lib/serverspec_extended_types/http_get.rb
# see also the `http` InSpec audit resource
# https://github.com/inspec/inspec/blob/master/lib/resources/http.rb
require 'faraday'
require 'json'

module Serverspec
  module Type

    class Http_Get < Base

      # Http status codes that are tested against for redirect test
      @@redirect_codes = [301, 302, 307, 308]

      def initialize(port, host_header, path, protocol = 'http', bypass_ssl_verify = false, timeout_sec = 10)
        @ip = ENV['TARGET_HOST'] || 'localhost'
        # TODO: ip is incorrecty set under uru
        # STDERR.puts "ip = #{@ip}"
        @ip = 'localhost'
        @port = port
        @protocol = protocol
        @host = host_header
        @redirects = false
        @redirect_path = nil
        @path = path
        @timed_out_status = false
        @content_str = nil
        @headers_hash = nil
        @response_code_int = nil
        @response_json = nil
        max_retry = 10
        default_delay = 3
        start_time = Time.now
        while (Time.now - start_time) < max_retry * default_delay
        begin
          getpage
          return if ! @response_code_int.nil?
        rescue  => e
          @timed_out_status = true
          STDERR.puts e.message
        end
          sleep default_delay
        end
      end

      def getpage
        ip = @ip
        port = @port
        options = []
        options << { ssl: { verify: false } } if @bypass_ssl_verify
        conn = Faraday.new("#{protocol}://#{ip}:#{port}/", *options)
        conn.headers[:user_agent] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"
        # conn.headers[:user_agent] = "Serverspec::Type::Http_Get/#{version} (https://github.com/jantman/serverspec-extended-types)"
        conn.headers[:Host] = @host
        response = conn.get(@path)
        @response_code_int = response.status
        @content_str = response.body
        @headers_hash = Hash.new('')
        @redirects = @@redirect_codes.include? @response_code_int
        @redirect_path = @redirects ? @headers_hash['location'] : nil
        response.headers.each do |header, val|
          @headers_hash[header] = val
        end
        # try to JSON decode
        begin
          @response_json = JSON.parse(@content_str)
        rescue
          @response_json = {}
        end
      end

      def timed_out?
        @timed_out_status
      end

      def headers
        @headers_hash
      end

      def json
        @response_json
      end

      def status
        if @timed_out_status
          0
        else
          @response_code_int
        end
      end

      def body
        @content_str
      end

      # Whether or not it redirects to some other page
      #
      # @example
      #   describe http_get(80, 'myhostname', '/') do
      #     it { should be_redirected_to 'https://myhostname/' }
      #   end
      #
      # @api public
      # @return [Boolean]
      def redirected_to? (redirect_path)
        @redirects and @redirect_path == redirect_path
      end

      # Whether or not it redirects to any other page
      #
      # @example
      #   describe http_get(80, 'myhostname', '/') do
      #     it { should be_redirected }
      #   end
      #
      # @api public
      # @return [Boolean]
      def redirected?
        @redirects
      end


      private :getpage
    end

    def http_get(port, host_header, path,  protocol = 'http', bypass_ssl_verify = false, timeout_sec = 10)
      Http_Get.new(port, host_header, path, protocol, bypass_ssl_verify, timeout_sec)
    end
  end
end

include Serverspec::Type
