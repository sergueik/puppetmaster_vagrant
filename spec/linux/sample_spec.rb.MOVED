require 'spec_helper'
context 'Perl Packages' do
  @cpan_modules = { 
    'Data::Validate::IP' => '0.10',
    'DBD::mysql'         => '4.013',
    'DBI'                => '1.609',
    'IPC::ShareLite'     => '0.17',
    'Net::hostent'       => '1.01',
    'Net::Netmask'       => '1.9015',
    'Net::Ping'          => '2.36',
    'Time::HiRes'        => '1.9726',
    'XML::Parser'        => '2.44',
    'XML::Simple'        => '2.18',
    'XML::XPath'         => '1.13',
  }
 @cpan_rpm_modules = [
   'perl-Data-Validate-IP',
   'perl-DBI',
   'perl-DBD-MySQL',
   'perl-IPC-ShareLite',
   # NOTE: 'perl-Net-hostent', 'perl-Net-Netmask', 'perl-Net-Ping' comes installed with perl itself
   'perl-Time-HiRes',
   'perl-XML-Parser',
   'perl-XML-Simple',
   'perl-XML-XPath'
  ] 
  @cpan_rpm_modules.each do |cpan_rpm_module| 
    describe package cpan_rpm_module do 
      it { should be_installed }
    end  
  end  
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
