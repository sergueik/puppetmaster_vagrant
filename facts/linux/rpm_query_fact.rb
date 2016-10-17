#!/usr/bin/env ruby

require 'facter'

#Name of this fact.
fact_name = 'product_version'

if Facter.value(:kernel) == 'windows'
else
  Facter.add(fact_name) do
    setcode do
      version = nil
      package_name = '<name of the yum package>'
      version = Facter::Util::Resolution.exec("rpm --queryformat '%{V}-%{R}' -q '#{package_name}' | grep -v 'not installed'" )
      if !version.nil? && !Regexp.new('\d+\.\d+\.\d+\.\d+').match(version)
        version = nil
      end
      version
    end
  end
end
