RSpec::Matchers.define :have_count do |count|
  match do |actual|
    actual.length ==  count
  end
  description do
    "have #{count}"
  end
  failure_message do |actual|
    "expected count to be #{count} was #{actual.length}"
  end
end