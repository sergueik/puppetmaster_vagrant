RSpec::Matchers.define :have_mount do |source, target, type = 'bind'|
  match do |actual|
    actual.has_mount?(source, target, type)
  end
  description do
    "mount #{source} on host to #{target} in container as a #{type} mount"
  end
  failure_message do |actual|
    "expected #{actual.mounts} to contain {'Target' => #{target}, 'Destination' => #{source} , 'Type' => #{type}}"
  end
end
