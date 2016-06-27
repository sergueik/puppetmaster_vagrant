require 'spec_helper'

describe port(3389) do
  it { should be_listening.with('udp')  }
  it { should be_listening.with('tcp')  }
end


describe file('c:/windows') do
  it { should be_directory }
end
