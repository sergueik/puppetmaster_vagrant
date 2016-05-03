RSpec::Matchers.define :have_configuration do |key|
  match do |subject|
    subject.has_configuration?(key, @value)
  end

  description do
    message = %(have configuration "#{key}")
    message << %( with value "#{@value}") if @value
    message
  end

  chain :with_value do |value|
    @value = value
  end

end
