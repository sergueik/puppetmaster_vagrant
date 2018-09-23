RSpec::Matchers.define :mirror_all do
  match do |actual|
    actual.mirror_all?
  end
end