require 'spec_helper'
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
require_relative '../type/http_get'

describe 'http_get' do
  context 'Serverspec::Type method' do
    it 'constructor parameters' do
      expect(Serverspec::Type::Http_Get).to receive(:new).with(80, 'hostheader', 'path', 'http', false, timeout_sec = 1)
      http_get(80, 'hostheader', 'path', timeout_sec= 1)
    end
    it 'respond with' do
      expect(Serverspec::Type::Http_Get).to receive(:new).and_return('response')
      expect(http_get(80, 'hostheader', 'path', timeout_sec = 1)).to eq 'response'
    end
  end
  context 'initialize' do
    it 'sets instance variables' do
      expect_any_instance_of(Serverspec::Type::Http_Get).to receive(:getpage).once
      stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'target_host'))
      x = http_get(80, 'hostheader', 'path', timeout_sec = 1)
      expect(x.instance_variable_get(:@ip)).to eq 'target_host'
      expect(x.instance_variable_get(:@port)).to eq 80
      expect(x.instance_variable_get(:@host)).to eq 'hostheader'
      expect(x.instance_variable_get(:@path)).to eq 'path'
      expect(x.instance_variable_get(:@timed_out_status)).to eq false
      expect(x.instance_variable_get(:@content_str)).to be nil
      expect(x.instance_variable_get(:@headers_hash)).to be nil
      expect(x.instance_variable_get(:@response_code_int)).to be nil
      expect(x.instance_variable_get(:@response_json)).to be nil
      expect(x.instance_variable_get(:@protocol)).to eq 'http'
      expect(x.instance_variable_get(:@bypass_ssl_verify)).to eq false
    end
    it 'calls ge' do
      expect_any_instance_of(Serverspec::Type::Http_Get).to receive(:getpage).once
      x = http_get(80, 'hostheader', 'path', timeout_sec = 1)
      expect(x.instance_variable_get(:@timed_out_status)).to eq false
    end
    it 'runs with a timeout' do
      expect(Timeout).to receive(:timeout).with(10)
      x = http_get(80, 'hostheader', 'path')
      expect(x.instance_variable_get(:@timed_out_status)).to eq false
    end
    it 'runs with specified timeout' do
      expect(Timeout).to receive(:timeout).with(123)
      x = http_get(80, 'hostheader', 'path', timeout_sec=123)
      expect(x.instance_variable_get(:@timed_out_status)).to eq false
    end
    it 'sets timed_out_status on timeout' do
      expect(Timeout).to receive(:timeout).with(10).and_raise(Timeout::Error)
      x = http_get(80, 'hostheader', 'path', timeout_sec=10)
      expect(x.instance_variable_get(:@timed_out_status)).to eq true
      expect(x.timed_out?).to eq true
      expect(x.status).to eq 0
    end
  end
  context '#getpage' do
    it 'requests the page' do
      stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'target_host'))
      conn = double
      headers = double
      
      expect(headers).to receive(:[]=).with(:user_agent, %r'Mozilla/\d+\.\d+ \(Windows; U; Windows NT \d+.\d+; de; rv:1\d+\.\d+\.\d+\.\d+\) Gecko/20100401 Firefox/\d+\.\d+\.\d+')
      expect(conn).to receive(:headers).and_return(headers)
      expect(headers).to receive(:[]=).with(:Host, 'hostheader')
      expect(conn).to receive(:headers).and_return(headers)
      response = double
      expect(response).to receive(:status).and_return(200)
      expect(response).to receive(:body).and_return('body')
      expect(response).to receive(:headers).and_return({'h1' => 'val', 'h2' => 'val'})
      expect(conn).to receive(:get).with('path').and_return(response)
      expect(Faraday).to receive(:new).with("http://target_host:80/").and_return(conn)
      x = http_get(80, 'hostheader', 'path')
      expect(x.timed_out?).to eq false
      expect(x.status).to eq 200
      expect(x.body).to eq 'body'
      expected_headers = {'h1' => 'val', 'h2' => 'val'}
      expect(x.headers).to eq expected_headers
      expect(x.json).to be_empty
      expect(x.json).to be_a_kind_of(Hash)
    end
    it 'supports https' do
      # boilerplate
      stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'target_host'))
      headers = double
      expect(headers).to receive(:[]=).with(:user_agent, %r'Mozilla/\d+\.\d+ \(Windows; U; Windows NT \d+.\d+; de; rv:1\d+\.\d+\.\d+\.\d+\) Gecko/20100401 Firefox/\d+\.\d+\.\d+')
      expect(headers).to receive(:[]=).with(:Host, 'hostheader')
      conn = double(headers: headers)
      response = double(status: 200, body: 'OK', headers: [])
      expect(conn).to receive(:get).with('path').and_return(response)
      # most importantly, we want https here
      expect(Faraday).to receive(:new).with("https://myhost:80/").and_return(conn)
      x = http_get(80, 'hostheader', 'path', 30, 'https')
    end
    it 'supports ssl verify bypass for self-signed certificates' do
      stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'tager_host'))
      headers = double
      expect(headers).to receive(:[]=).with(:user_agent, %r"Serverspec::Type::Http_Get/\d+\.\d+\.\d+ \(https://github.com/jantman/serverspec-extended-types\)")
      expect(headers).to receive(:[]=).with(:Host, 'hostheader')
      conn = double(headers: headers)
      response = double(status: 200, body: 'OK', headers: [])
      expect(conn).to receive(:get).with('path').and_return(response)
      # most importantly, we want https here
      expect(Faraday).to receive(:new).with("https://myhost:80/", {ssl: {verify: false}}).and_return(conn)
      x = http_get(80, 'hostheader', 'path', 30, 'https', true)
    end
    it 'Constructs JSON if parsable' do
      stub_const('ENV', ENV.to_hash.merge('TARGET_HOST' => 'target_host'))
      conn = double
      headers = double
      expect(headers).to receive(:[]=).with(:user_agent, %r"Serverspec::Type::Http_Get/\d+\.\d+\.\d+ \(https://github.com/jantman/serverspec-extended-types\)")
      expect(conn).to receive(:headers).and_return(headers)
      expect(headers).to receive(:[]=).with(:Host, 'hostheader')
      expect(conn).to receive(:headers).and_return(headers)
      response = double
      expect(response).to receive(:status).and_return(200)
      expect(response).to receive(:body).and_return('{"foo": "bar", "baz": {"blam": "blarg"}}')
      expect(response).to receive(:headers).and_return({'h1' => 'val', 'h2' => 'val'})
      expect(conn).to receive(:get).with('path').and_return(response)
      expect(Faraday).to receive(:new).with("http://target_host:80/").and_return(conn)
      x = http_get(80, 'hostheader', 'path')
      expect(x.timed_out?).to eq false
      expect(x.status).to eq 200
      expect(x.body).to eq '{"foo": "bar", "baz": {"blam": "blarg"}}'
      expected_headers = {'h1' => 'h1val', 'h2' => 'h2val'}
      expect(x.headers).to eq expected_headers
      expected_json = {"foo" => "bar", "baz" => {"blam" => "blarg"}}
      expect(x.json).to eq expected_json
    end
  end
end