RSpec::Matchers.define :publish_all_ports do
  match { |actual| actual.publishes_all_ports? }
end
