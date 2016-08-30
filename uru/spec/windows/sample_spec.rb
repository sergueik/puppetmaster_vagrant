require_relative '../windows_spec_helper'

context 'uru smoke test' do
  context 'basic os tests' do
    describe port(3389) do
      it do
       should be_listening.with('tcp')
       should be_listening.with('udp')
      end
    end

    describe file('c:/windows') do
      it { should be_directory }
    end
  end

  context 'detect uru environment' do
    describe command(<<-EOF
     pushd env:
     dir 'PATH' | format-list
     popd
      EOF
    ) do
      # could fail if the .gems are put under $HOME and added to the $PATH
      its(:stdout) { should match Regexp.new('_U1_;c:\\\\uru\\\\ruby\\\\bin;_U2_;', Regexp::IGNORECASE) }
    end
  end 
end