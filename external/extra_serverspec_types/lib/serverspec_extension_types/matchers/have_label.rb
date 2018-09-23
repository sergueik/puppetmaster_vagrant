RSpec::Matchers.define :have_label do |label|
  match do |actual|
    actual.labels.key? label
  end
  failure_message do |actual|
    "expected #{actual.labels} to have key #{label}"
  end
end

RSpec::Matchers.define :have_label_with_value do |label, value|
  match do |actual|
    actual.labels[label] == value
  end
  failure_message do |actual|
    "expected #{actual.labels[label]} to be #{value}"
  end
  description do
    "have label #{label} with value #{value}"
  end
end