RSpec::Matchers.define :read_from_queue do |vhost, queue|
  match do |actual|
    actual.read_from_queue?(vhost, queue)
  end
  description do
    "be able to read from #{queue} on the #{vhost} vhost"
  end
end
