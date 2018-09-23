RSpec::Matchers.define :configure_queue do |vhost, queue|
  match do |actual|
   actual.configure_queue? vhost, queue
  end
  description do
    "be able configure #{queue} on the #{vhost} vhost"
  end
end
