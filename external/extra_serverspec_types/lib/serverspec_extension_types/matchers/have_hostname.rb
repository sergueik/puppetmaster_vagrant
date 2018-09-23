RSpec::Matchers.define :have_hostname do |hostname|
  match do |actual|
    actual.has_hostname? hostname
  end
end
RSpec::Matchers.alias_matcher :have_host_name, :have_hostname
