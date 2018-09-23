RSpec::Matchers.define :map_port do |host, container|

  match do |actual|
    @protocol = 'tcp' unless @protocol
    if @mode
      actual.map_port? host, container, @protocol, @mode
    else
      actual.map_port? host, container, @protocol
    end
  end
  description do
    msg = "map container port #{container} to host port #{host}"
    msg << %( using the "#{@protocol}" protocol) if @protocol
    msg << %( in "#{@mode}" mode) if @mode
    msg
  end
  failure_message do |actual|
    @protocol = 'tcp' unless @protocol
    "expected #{actual.port_map} to contain {\"#{container}/#{@protocol}\"=>[{\"HostPort\"=>\"#{host}\"}] }"
  end

  chain :using_protocol, :protocol
  chain :with_mode, :mode

end