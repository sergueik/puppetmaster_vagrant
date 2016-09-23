require_relative '../windows_spec_helper'

context 'Multiple Product Versions Acceptable' do
  latest_version = '2'
  latest_build = '00'
  previous_version = '1'
  previous_build = '00'
  context 'Package' do
    describe package(actual_package_name) do
      it { should be_installed  }
      # cannot expect - e.g. region differences
      xit { should be_installed.with_version("#{latest_version}.#{latest_build}") }
    end
    product_version = 'product_version'
    # NOTE: Redirection to 'NUL' failed: FileStream will not open Win32 devices such as disk partitions and tape drives. Avoid use of "\\.\" in the path.
    describe command(<<-EOF
    $product_version = '#{product_version}'
    $data =  & "C:\\Program Files\\Puppet Labs\\Puppet\\bin\\facter.bat" --puppet "${product_version}" 2> 1
    write-output $data
    EOF
    ) do
      its(:stdout) { should match /(#{previous_version}.#{previous_build}|#{latest_version}.#{latest_build})/ }
    end
  end
end
