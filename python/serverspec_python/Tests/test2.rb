# This is a sample test
describe "Hello" do
  describe command('echo Hello') do
    its(:stdout) { should match 'Hello' }
  end
end
