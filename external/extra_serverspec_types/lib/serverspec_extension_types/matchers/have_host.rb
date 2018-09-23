RSpec::Matchers.define :have_host do |host|
  match do |actual|
    actual.has_host? host
  end
  failure_message do |actual|
    "expected #{actual.hosts} to contain #{host}"
  end
end
