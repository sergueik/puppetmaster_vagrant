RSpec::Matchers.define :have_replica_count do |count|
  match do |actual|
    actual.replicas == count
  end
  description do
    "have #{count} replica#{count != 1 ? 's' : ''}"
  end
end
