require_relative '../windows_spec_helper'

context 'Command Line Arguments of Windows Process' do
  # NOTE: error in http://serverspec.org/resource_types.html#process
  # for Windows, property "args" cannot be found
  # However the error stack contains sufficient information to figure out the correct syntax:
  # The its(:args) { should contain } spec translates simply into Powershell command
  # Get-WmiObject Win32_Process -Filter "name = 'powershell`.exe'" | select -First 1 args -ExpandProperty args
  # so the following works fine:

  describe process('powershell.exe') do
    it { should be_running }
    its(:CommandLine) { should match /C:\\Windows\\System32\\WindowsPowerShell\\v1.0\powershell.exe/i }
  end
end