RSpec::Matchers.define :have_network do |name|
  match do |actual|
    actual.has_network? name
  end
  failure_message do |actual|
    "expected #{actual.networks} to include #{name}"
  end
end