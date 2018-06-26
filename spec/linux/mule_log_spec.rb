require 'spec_helper'

context 'Mule Enterprise Log files' do

  log_path = '/usr/share/mulee/logs'
  log_line = 'Valid license key --> Evaluation = false, Expiration Date ='

  # NOTE: mule is usually configured with log rotation
  # the following nive expectation would fail:
  describe file("#{log_path}/mule_ee.log") do
    its(:content) {  should match log_line }
  end
  file_count = 0
  [
    'mule_ee.log',
    'mule_ee.log.*'
  ].each do |log_file|
    file_mask = log_path + '/' + log_file
    Dir.glob(file_mask).each do |filepath|
      describe file(fielpath) do
        it { should be_file }
      end
      File.readlines(filepath).each do |line|
        if line =~ Regexp.new(Regexp.escape(log_line))
          $stderr.puts line
          file_count = file_count + 1
        end
      end
    end
  end
  describ(file_count) do
    it {should be > 0 }
  end

  # alternatively one can use grep command to find license information.
  # in one of the logs contain
  describe command("grep -il #{log_line} mule_ee.log mule_ee.log.*") do
    its(:exit_status) {should eq 0}
  end
end
