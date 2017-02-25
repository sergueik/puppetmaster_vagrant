require 'spec_helper'

context 'Orphaned Files' do
  rootdir = '/scratch'
  describe command(<<-EOF
   /usr/bin/find "#{rootdir}" -xdev \\( -type f -or -type d \\) -and \\( -nouser -or -nogroup \\)
  EOF
  ) do
    its(:stdout) { should be_empty }
    its(:stderr) { should be_empty }
  end
end
