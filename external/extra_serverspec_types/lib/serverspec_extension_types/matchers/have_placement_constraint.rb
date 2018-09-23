RSpec::Matchers.define :have_placement_constraint do |constraint|
  match do |actual|
    actual.has_placement_constraint? constraint
  end
  failure_message do |actual|
    "expected #{actual.placement_constraint} to include #{constraint}"
  end
end