# based on: https://github.com/jantman/serverspec-extended-types/blob/master/lib/serverspec_extended_types/http_get.rb

require 'faraday'
require 'json'

module Serverspec
  module Type

    class Http_Get < Base

      def initialize(port, host_header, path, protocol = 'http', timeout_sec=10)
        @ip = ENV['TARGET_HOST'] || 'localhost'
        # TODO: incorrecty set under uru
        # STDERR.puts "ip = #{@ip}"
        @ip = 'localhost'
        @port = port
        @protocol = protocol
        @host = host_header
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
        if protocol == 'https'
          conn = Faraday.new "https://#{ip}:#{port}/", :ssl => {:verify => false}
        else
          conn = Faraday.new "http://#{ip}:#{port}/"
        end
        conn.headers[:user_agent] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"
        conn.headers[:Host] = @host
        response = conn.get(@path)
        @response_code_int = response.status
        @content_str = response.body
        @headers_hash = Hash.new('')
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

      private :getpage
    end

    def http_get(port, host_header, path, protocol = 'http', timeout_sec=10)
      Http_Get.new(port, host_header, path, protocol, timeout_sec=timeout_sec)
    end
  end
end

include Serverspec::Type