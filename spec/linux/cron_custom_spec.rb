require 'spec_helper'
require_relative '../type/cron'

describe cron do
  it { should have_entry '0 0 * * * /etc/cron.daily/script' }
  it { should have_entry '0 0 * * * find /usr/share/tomcat/logs/ -type f -mtime +30 -exec rm -rf {} \;' }
  # echo '0 0 * * * find /usr/share/tomcat/logs/ -type f -mtime +30 -exec rm -rf {} \;' | grep -q '0 0 \* *\* *\* *find */usr/share/tomcat/logs/ *\- *type *f *\-mtime *+30 *\-exec *rm *\-rf *{} *\\;'
end
