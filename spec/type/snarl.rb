require 'socket'

# origin https://github.com/luislavena/net-snarl
# NOTE: this code does not do anything

# NOTE: the https://github.com/githubsvnclone/ruby-snarl
# uses SendMessage to communicate with https://github.com/fullphat/snarl 
# but is not compatible with Ruby 2.x (because of  	 relying on dl that needs conversion to Struct / Win32API
# Snarl 3.1 is VB
# snarl 5.0 is C#
class Snarl
  HEADER = "type=SNP".freeze
  PROTOCOL_VERSION = "version=1.0".freeze
  TERMINATOR = "\r\n".freeze
  DEFAULT_TIMEOUT = 10

  attr_reader :host, :port

  def initialize(host = nil, port = nil)
    @host = host || '127.0.0.1'
    @port = (port || 9887).to_i
  end

  def notify(params = {})
    add_defaults(params)

    connected { |c| c.write command('notification', params) }
  end

  def register(app)
    connected { |c| c.write command('register', :app => app) }
  end

  def unregister(app)
    connected { |c| c.write command('unregister', :app => app) }
  end

  def add_class(app, klass, params = {})
    params[:app] = app
    params[:class] = klass

    connected { |c| c.write command('add_class', params) }
  end

  def hello
    connected { |c| c.write command('hello') }
  end

  def version
    connected { |c| c.write command('version') }
  end

  def inspect
    version = hello.split('/').last
    "#<#{self.class} host=#{@host}, port=#{@port}, version=#{version.inspect}>"
  end

  private

  def command(action, params = {})
    cmd = [HEADER, PROTOCOL_VERSION, "action=#{action}"]

    params.each do |k, v|
      cmd << "#{k}=#{v}"
    end

    cmd.join('#?') + TERMINATOR
  end

  def add_defaults(params)
    params[:timeout] ||= DEFAULT_TIMEOUT
    params
  end

  def connected
    TCPSocket.open(@host, @port) do |s|
      yield s
      s.gets.chomp
    end
  end
end

