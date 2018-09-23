RSpec::Matchers.define :have_user do |user|
  match do |actual|
    actual.has_user? user
  end
  failure_message do |actual|
    "expected user to be #{user} was #{actual.user}"
  end
end

RSpec::Matchers.alias_matcher :run_as_user, :have_user