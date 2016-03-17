require_relative '../windows_spec_helper'
context 'Path environment' do
  describe command ("([Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine))") do 
    its(:stdout) { should match /c:\\+windows\\+tools/io }
  end
end
