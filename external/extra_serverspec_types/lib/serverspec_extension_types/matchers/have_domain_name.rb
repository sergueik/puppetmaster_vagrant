RSpec::Matchers.define :have_domainname do |domain|
  match do |actual|
    actual.has_domainname? domain
  end
  failure_message do |actual|
    "expected domain name to be #{domain}, was #{actual.domain_name}"
  end
end

RSpec::Matchers.alias_matcher :have_domain_name, :have_domainname
