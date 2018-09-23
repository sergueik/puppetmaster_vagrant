RSpec::Matchers.define :include_regex do |regex|
  match do |actual|
    actual.include_regex? regex
  end
end
