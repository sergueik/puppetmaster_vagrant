RSpec::Matchers.define :have_restart_policy do |policy|
  match do |actual|
    actual.has_restart_policy?(policy)
  end
  failure_message do |actual|
    "expected restart policy to be #{policy}, was #{actual.restart_policy}"
  end
end
