RSpec::Matchers.define :have_enabled_app do |app|
  match do |subject|
    subject.has_enabled_app?(app, @version)
  end

  description do
    message = %(have enabled app "#{app}")
    message << %( with version "#{@version}") if @version
    message
  end

  chain :with_version do |version|
    @version = version
  end

end
