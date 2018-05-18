class Specinfra::Command::Base::Firewalld < Specinfra::Command::Base
  class << self
    def get_default_zone
      "firewall-cmd --get-default-zone"
    end

    def check_has_service(service, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}" if zone
      cmd += " --query-service=#{escape(service)}"
      cmd
    end

    def check_has_port(port, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}" if zone
      cmd += " --query-port=#{escape(port)}"
      cmd
    end

    def check_has_interface(interface, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}" if zone
      cmd += " --query-interface=#{escape(interface)}"
      cmd
    end

    def check_has_source(source, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}"
      cmd += " --query-source=#{escape(source)}"
      cmd
    end

    def check_has_rich_rule(rule, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      if rule.kind_of?(Hash)
        _rule =  "rule"
        _rule += " family=#{escape(rule[:family])}" if rule[:family]
        _rule += " source address=#{escape(rule[:source])}" if rule[:source]
        _rule += " destination address=#{escape(rule[:destination])}" if rule[:destination]
        _rule += " service name=#{escape(rule[:service])}" if rule[:service]
        _rule += " protocol value=#{escape(rule[:protocol])}" if rule[:protocol]
        if rule[:port]
          _rule += " port"
          _rule += " port=#{escape(rule[:port][:port])}" if rule[:port][:port]
          _rule += " protocol=#{escape(rule[:port][:protocol])}" if rule[:port][:protocol]
        end
        if rule[:log]
          _rule += " log"
          _rule += " prefix=#{escape(rule[:log][:prefix])}" if rule[:log][:prefix]
          _rule += " level=#{escape(rule[:log][:level])}" if rule[:log][:level]
        end
        _rule += " #{escape(rule[:action])}" if rule[:action]
        rule = _rule
        cmd += " --permanent" if permanent
        cmd += " --zone=#{escape(zone)}" if zone
        cmd += " --query-rich-rule='#{rule}'"
      else
        cmd += " --permanent" if permanent
        cmd += " --zone=#{escape(zone)}" if zone
        cmd += " --list-rich-rules"
        cmd += " | grep -- #{escape(rule)}"
      end
      cmd
    end

    def check_has_icmp_block(icmptype, zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}" if zone
      cmd += " --query-icmp-block='#{icmptype}'"
      cmd
    end

    def check_enabled_masquerade(zone = nil, permanent = false)
      cmd =  "firewall-cmd"
      cmd += " --permanent" if permanent
      cmd += " --zone=#{escape(zone)}" if zone
      cmd += " --query-masquerade"
      cmd
    end
  end
end
