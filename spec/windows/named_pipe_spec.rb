require_relative '../windows_spec_helper'
# http://stackoverflow.com/questions/258701/how-can-i-get-a-list-of-all-open-named-pipes-in-windows
context 'Pipes' do
  standard_named_pipes = %w|
    //./pipe/atsvc
    //./pipe/browser
    //./pipe/eventlog
    //./pipe/lsass
    //./pipe/ntsvcs
    //./pipe/spoolss
    //./pipe/wkssvc
  |
  describe command(<<-EOF
  [String[]]$pipes = [System.IO.Directory]::GetFiles('\\\\.\\pipe\\')
  format-list -inputobject ($pipes -replace '\\\\', '/' )'
  EOF
  ) do
    standard_named_pipes.each do |named_pipe|
      its (:stdout) { should contain named_pipe }
    end
  end
end
