RSpec::Matchers.define :be_a_manager_node do
  match do |actual|
    actual.role == 'manager'
  end
  failure_message do |actual|
    "expected '#{actual.role}' to be manager"
  end
  description do
    'be a manager node'
  end
end

RSpec::Matchers.alias_matcher :be_manager, :be_a_manager_node
RSpec::Matchers.alias_matcher :be_a_manager, :be_a_manager_node
RSpec::Matchers.alias_matcher :be_manager_node, :be_a_manager_node