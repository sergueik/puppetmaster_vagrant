RSpec::Matchers.define :have_engine_version do |version|
  match do |actual|
    actual.has_engine_version? version
  end
  failure_message do |actual|
    "expected version #{actual.engine_version} to be #{version}"
  end
  description do
    "be running docker version #{version}"
  end
end