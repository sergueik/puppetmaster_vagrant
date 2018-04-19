require 'spec_helper'

# based on https://github.com/emmafass/serverspec-custom-types/blob/master/lib/serverspec-custom-types/timezone.rb
content 'TimeZone' do
  timezone = 'America/New_York (EDT, -0400)'
  describe command('/usr/bin/timedatectl') do
    #     Local time: Wed 2017-07-19 22:03:26 EDT
    # Universal time: Thu 2017-07-20 02:03:26 UTC
    #       RTC time: Thu 2017-07-20 02:03:26
    #      Time zone: America/New_York (EDT, -0400)
    its(:stdout) { should match Regexp.new("Time zone: #{timezone}")}
  end
end
