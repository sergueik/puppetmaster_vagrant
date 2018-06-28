require 'spec_helper'

context 'Mule Enterprise Log files' do

  mule_log_path = '/usr/share/mulee/logs'
  mule_bin_path = '/usr/share/mulee/bin'
  log_line = 'Valid license key --> Evaluation = false, Expiration Date ='

  # NOTE: mule is usually configured with log rotation
  # the following nive expectation would fail:
  describe file("#{mule_log_path}/mule_ee.log") do
    its(:content) {  should match log_line }
  end
  file_count = 0
  [
    'mule_ee.log',
    'mule_ee.log.*'
  ].each do |log_file|
    file_mask = mule_log_path + '/' + log_file
    Dir.glob(file_mask).each do |filepath|
      describe file(filepath) do
        it { should be_file }
      end
      File.readlines(filepath).select { |line| line =~ Regexp.new(Regexp.escape(log_line)) }.each do |line|
        $stderr.puts line
        file_count = file_count + 1
      end
    end
  end
  describe file_count do
    it { expect(subject).to be > 0 }
    it { should be > 0 }
  end

  # alternatively one can use grep command to find license information.
  # in one of the logs contain the log_line.
  # NOTE: the test will fail when there is no mule_ee.log.*  
  describe command(<<-EOF
    cd '#{mule_log_path}'
    touch mule_ee.log.1
    grep -il '#{log_line}' mule_ee.log mule_ee.log.*
  EOF
  ) do
    its(:exit_status) { should eq 0 }
  end
  # alternatively one can restrict the test to the local developer Vagrantbox run 
  # and run mule command to show expiration date of the license - this requires stopping the mule service
  # https://forums.mulesoft.com/questions/2039/how-can-i-check-the-expiry-date-of-mule-server-license.html
  describe command(<<-EOF
    systemctl stop mule
    cd '#{mule_bin_path}'
    ./mule -verifyLicense 
  EOF
  ) do
    its(:stdout) { should match Regexp.new(Regexp.escape(log_line)) }
  end
end
