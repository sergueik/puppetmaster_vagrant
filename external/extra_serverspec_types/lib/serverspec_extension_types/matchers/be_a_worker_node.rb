RSpec::Matchers.define :be_a_worker_node do
  match do |actual|
    actual.role == 'worker'
  end
  failure_message do |actual|
    "expected '#{actual.role}' to be worker"
  end
  description do
    'be a worker node'
  end
end
RSpec::Matchers.alias_matcher :be_worker, :be_a_worker_node
RSpec::Matchers.alias_matcher :be_a_worker, :be_a_worker_node
RSpec::Matchers.alias_matcher :be_worker_node, :be_a_worker_node