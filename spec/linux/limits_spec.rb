require 'spec_helper'

# origin: https://unix.stackexchange.com/questions/345595/how-to-set-ulimits-on-service-with-systemd
# https://stackoverflow.com/questions/21752067/counting-open-files-per-process
context 'file limit' do
  jar_filename = 'org.eclipse.equinox.launcher'
  max_open_files = 1048576
  jar_filename_changed = jar_filename.gsub(/^(\w)/,'[\1]')
  describe command( <<-EOF
    cat /proc/$(ps ax | grep "#{jar_filename_changed}"|head -1 | awk '{print $1}')/limits
  EOF
  ) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match Regexp.new("Max open files *#{max_open_files} *#{max_open_files} *files", Regexp::IGNORECASE) }
    its(:stderr) { should be_empty }
  end
end
