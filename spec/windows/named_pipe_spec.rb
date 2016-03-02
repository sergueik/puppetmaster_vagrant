require_relative '../windows_spec_helper'

context 'Pipes' do
  named_pipe = '//./pipe/eventlog'
  # http://stackoverflow.com/questions/258701/how-can-i-get-a-list-of-all-open-named-pipes-in-windows
  describe command('[String[]]$pipes = [System.IO.Directory]::GetFiles("\\\\.\pipe\\"); format-list -inputobject ($pipes -replace "\\\\", "/" )') do
    its (:stdout) { should contain named_pipe }
  end
end
