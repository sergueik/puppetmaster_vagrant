require 'spec_helper'
require 'socket'
require 'timeout'

HTTP_PORT = 80
HTTPS_PORT = 443
TIMEOUT = 3

def is_port_open(ip, port)
  begin
    Timeout::timeout(TIMEOUT) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error => e
  end
  return false
end

describe 'Socket test with timeout' do
  it "should refuse connections to port #{HTTPS_PORT}" do
    expect(is_port_open('127.0.0.1', HTTPS_PORT)).to be false
  end
end
