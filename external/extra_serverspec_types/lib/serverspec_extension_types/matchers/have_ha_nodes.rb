RSpec::Matchers.define :have_ha_nodes do |count|
  match do |actual|
    actual.has_ha_nodes? count
  end
  description do
    "have #{count} ha nodes"
  end
end
