# require 'spec_helper'

context 'Valid symlink' do
  [
    '/usr/bin/pip-python',
    '/usr/bin/VBoxClient',
  ].each do |filepath|
    describe file(filepath) do
      it { should be_symlink }
      # a home-brewed version of `should be_linked_to`
      split_filename_from_filepath = Regexp.new('^(.+)/([^/]+)$').match(filepath)
      dir = split_filename_from_filepath[1]
      filename = split_filename_from_filepath[2]
      describe command(<<-EOF
        find #{dir} -type l -and -name '#{filename}' -exec test -e {} \\; -print
      EOF
      ) do
        its(:stdout) { should_not be_empty }
      end
    end
  end
end
