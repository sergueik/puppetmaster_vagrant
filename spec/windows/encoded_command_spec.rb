require_relative '../windows_spec_helper'
context 'Encoded Command' do
  # http://blogs.msdn.com/b/timid/archive/2014/03/26/powershell-encodedcommand-and-round-trips.aspx
  #
  #  $command = 'dir "c:\program files" '
  #  $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
  #  $encodedCommand = [Convert]::ToBase64String($bytes)
  #
  encoded_command = 'ZABpAHIAIAAiAGMAOgBcAHAAcgBvAGcAcgBhAG0AIABmAGkAbABlAHMAIgAgAA=='
  describe command(<<-EOF
    $encodedCommand = '#{encoded_command}'
    powershell.exe -encodedCommand $encodedCommand
    EOF
    ) do
    its(:stdout) do
      should contain 'Directory: C:\program files'
    end 
  end
end
