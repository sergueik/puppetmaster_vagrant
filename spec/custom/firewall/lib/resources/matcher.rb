RSpec::Matchers.define :have_port do |port|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_port?(port, @zone, @permanent)
    else
      subject.has_port?(port)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have port \"#{port}\""
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :have_service do |service|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_service?(service, @zone, @permanent)
    else
      subject.has_service?(service)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have service \"#{service}\""
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :have_interface do |interface|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_interface?(interface, @zone, @permanent)
    else
      subject.has_interface?(interface)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have interface \"#{interface}\""
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :have_source do |source|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_source?(source, @zone, @permanent)
    else
      subject.has_source?(source)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have source \"#{source}\""
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :have_rich_rule do |rule|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_rich_rule?(rule, @zone, @permanent)
    else
      subject.has_rich_rule?(rule)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have rich rule \"#{rule}\""
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :have_icmp_block do |icmptype|
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.has_icmp_block?(icmptype, @zone, @permanent)
    else
      subject.has_icmp_block?(icmptype)
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "have icmp block"
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end

RSpec::Matchers.define :be_enabled_masquerade do
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Firewalld'
      subject.enabled_masquerade?(@zone, @permanent)
    else
      subject.enabled_masquerade?
    end
  end

  chain :with_zone do |zone|
    @zone = zone
  end

  chain :with_permanent do
    @permanent = true
  end

  description do
    desc =  "enabled masquerade"
    desc += " with zone \"#{@zone}\"" if @zone
    desc += " with permanent" if @permanent
    desc
  end
end
