require 'spec_helper'
require_relative '../type/cron'

describe cron do
  it { should have_entry '0 0 * * * /etc/cron.daily/script' }
end
