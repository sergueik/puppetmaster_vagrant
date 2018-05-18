module Serverspec::Type
  class Firewalld < Base
    def default_zone
      @runner.get_firewalld_default_zone().stdout
    end

    def has_service?(service, zone, permanent)
      @runner.check_firewalld_has_service(service, zone, permanent)
    end

    def has_port?(port, zone, permanent)
      @runner.check_firewalld_has_port(port, zone, permanent)
    end

    def has_interface?(interface, zone, permanent)
      @runner.check_firewalld_has_interface(interface, zone, permanent)
    end

    def has_source?(source, zone, permanent)
      @runner.check_firewalld_has_source(source, zone, permanent)
    end

    def has_rich_rule?(rule, zone, permanent)
      @runner.check_firewalld_has_rich_rule(rule, zone, permanent)
    end

    def has_icmp_block?(icmptype, zone, permanent)
      @runner.check_firewalld_has_icmp_block(icmptype, zone, permanent)
    end

    def enabled_masquerade?(zone, permanent)
      @runner.check_firewalld_enabled_masquerade(zone, permanent)
    end

    def to_s
      'Firewalld'
    end
  end
end
