RSpec::Matchers.define :have_ha_sync_mode do |mode|
  match do |actual|
    actual.has_ha_sync_mode? mode
  end
end