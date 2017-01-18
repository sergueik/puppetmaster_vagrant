require 'spec_helper'

context 'DNS' do
  dns_suffix = 'local.dns'
  [
    %x( hostname -s).chomp! + dns_suffix
  ].each do |hostname_local_domain|
    describe host(hostname_local_domain) do
      it { should be_resolvable }
    end
  end
end
