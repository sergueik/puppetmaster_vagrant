RSpec::Matchers.define :have_restart_limit do |count|
  match do |actual|
    actual.has_restart_limit? count
  end
  failure_message do |actual|
    "expected restart limit to be #{count}, was #{actual.restart_limit}"
  end
end
