RSpec::Matchers.define :have_ha_mode do |mode|
  match do |actual|
    actual.has_ha_mode? mode
  end
end
