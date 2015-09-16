require 'spec_helper'
context 'Perl Packages' do
  @cpan_modules = { 
    'Time::HiRes'        => '1.9726',
    'IPC::ShareLite'     => '0.17',
    'XML::Simple'        => '2.18',
    'Net::Ping'          => '2.36',
    'Data::Validate::IP' => '0.10',
    'Net::Netmask'       => '1.9015',
    'Net::hostent'       => '1.01',
   # 'DBI'                => '?',
   # 'DBD::MySql'         => '?',
    'XML::XPath'         => '1.13',
    'XML::Parser'        => '2.44'
  }
  @cpan_modules.each do |_module,_version| 
    context "#{_module}" do
      describe command ("perl -M#{_module} -e 'print $#{_module}::VERSION'") do
        its(:stdout) { should match /#{_version}/ }
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
      end
    end
  end 
end
