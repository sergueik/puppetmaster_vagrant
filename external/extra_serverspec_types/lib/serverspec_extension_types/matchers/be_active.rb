RSpec::Matchers.define :be_active do
  match do |actual|
    actual.active?
  end
  failure_message do |actual|
    "expected '#{actual.availability}' to be active"
  end
  description do
    'be active'
  end
end
