require 'spec_helper'

context 'Tomcat rotated logs' do
  filecount = 0
  path = '/apps/tomcat/current/logs/'
  filemask = path + '/' + 'localhost.' + %x( date + '%F' ).chomp + '.log'
  Dir.glob( filemask ).each do |filename|
    describe file(filename) do
      it { should be_file }
      filecount = filecount + 1
    end
  end
  describe(filecount) do
    it { should_not be 0 }
  end
  context 'Exception check' do
    exception = 'com.tridion.licensing.LicenseViolationException'
    describe command("grep -i '#{exception}' '#{filemask}'") do
      its(:stdout) { should be_empty}
      its(:exit_status) { should_not be 0}
    end
  end
end
