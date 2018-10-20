# This is a sample test
describe "World" do
  describe command('echo World') do
    its(:stdout) { should match 'World' }
  end
end
