#!/usr/bin/env ruby

# Custom fact which returns rpm package version information 
# in custom format e.g. to simplify the hieradata key management

require 'facter'

# Name of the fact
fact_name = 'rpm_package_version'

# Code of the fact
def rpm_package_get_version
  package_name = 'package_name'
  Facter::Util::Resolution.exec("rpm -qa --queryformat '%{V}.%{R}.0' '#{package_name}'")
end
Facter.add(fact_name) do
  confine :kernel => :linux
  setcode do
    rpm_package_get_version
  end
end
