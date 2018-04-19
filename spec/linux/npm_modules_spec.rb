require 'spec_helper'

context 'Npm modules' do
  [
    'npm_lazy',
  ].each do |node_module|
    # NOTE: encode': "\xE2" from ASCII-8BIT to UTF-8 (Encoding::UndefinedConversionError)
    # TODo: use iconv
    describe command( "npm list #{node_module} -g | strings") do
      its(:stdout) { should match /#{package}@[\d\.]+\s*$/ }
      # WARN npm is likely to print to STEDRR various unmet dependencies
      # its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
