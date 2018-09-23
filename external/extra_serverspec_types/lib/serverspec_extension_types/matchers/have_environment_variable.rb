RSpec::Matchers.define :have_environment_variable do |regex|
  chain :with_value do | value|
    @value = value
  end
  match do |actual|
    actual.has_environment_variable? regex, @value
  end
  description do
    message = "have an environment variable #{regex}"
    message << %( with a value of "#{@value}") if @value
    message
  end
  failure_message do |actual|
    if !@value
      "expected #{actual.environment_variables} to contain #{regex}"
    else
      "expected #{regex} to have value #{@value}, it was #{actual.environment_variable(regex)}"
    end
  end

end
