RSpec::Matchers.define :write_to_queue do |vhost, queue|
  match do |actual|
    actual.write_to_queue? vhost, queue
  end
  description do
    "be able to write to #{queue} on the #{vhost} vhost"
  end
end
