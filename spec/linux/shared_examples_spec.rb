require 'spec_helper'
# based on: https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples
# https://github.com/mizzy/serverspec/blob/master/lib/serverspec/type/user.rb
# https://github.com/supercaracal/kitchen-pocapoca/blob/master/spec/shared/home/vim.rb

RSpec.shared_examples 'measurable object' do |result, instance_methods|
  instance_methods.each do |instance_method|
    it "should return #{result} from #{instance_method}" do
      expect(subject.send(instance_method)).to eq(result)
    end
  end
end

RSpec.describe Array, 'of 3 items' do
  subject { [1, 2, 3] }
  it_should_behave_like 'measurable object', 3, [:size, :length]
end

RSpec.describe String, 'of 6 characters' do
  subject { "FooBar" }
  it_should_behave_like 'measurable object', 6, [:size, :length]
end


RSpec.describe Serverspec::Type::User, 'osboxes' do
  subject { Serverspec::Type::User.new 'osboxes' }
  it_should_behave_like 'measurable object', '$6$5nSn1HH4/vjaabNj$vrXY1n0Z4aqufQkgH32CXlThozg9CS3IahaEawP4h6OyLIj7TbkpXQDeTCGg1KGq2.ah84D3nZWR7XoqqMjqh/', [:encrypted_password]
end
