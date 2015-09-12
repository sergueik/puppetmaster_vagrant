require 'spec_helper'
context 'Perl Packages' do
  context 'Time::Hires' do
    describe command ("perl -MTime::HiRes -e 'print $Time::HiRes::VERSION' ") do
      let(:version) { '1.9726' }
      its(:stdout) { should match /#{version}/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
  context 'Time::Hires' do
    describe command ("perl -MIPC::ShareLite -e 'print $IPC::ShareLite::VERSION' ") do
      let(:version) { '0.17' }
      its(:stdout) { should match /#{version}/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end

