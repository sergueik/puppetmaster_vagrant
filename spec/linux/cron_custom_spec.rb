require 'spec_helper'
require_relative '../type/cron'

context 'Customized cron resource' do
  describe cron do
    # crontab entry
    # 0 0 * * * /etc/cron.daily/script
    it { should have_entry '0 0 * * * /etc/cron.daily/script' }
  end

  describe cron do
    # crontab entry
    # 0 0 * * * find /usr/share/tomcat/logs/ -type f -mtime +30 -exec rm -rf {} \;
    # passing shell command
    # crontab -l | grep '0 0 \* *\* *\* *find */usr/share/tomcat/logs/ *\- *type *f *\-mtime *+30 *\-exec *rm *\-rf *{} *\\;'
    # serverspec
    it { should have_entry '0 0 * * * find /usr/share/tomcat/logs/ -type f -mtime +30 -exec rm -rf {} \;' }
  end

  describe cron do
    # crontab entry
    # 0 0 * * * /bin/find /tmp/repository/logs/ ! \\( -name "patches.*" -o -name "audit.*" \\) -type f -mtime +30 -exec rm -rf {} \\;
    # passing shell command
    # crontab -l | grep '0 0 \* \* \* /bin/find /tmp/repository/logs/ ! \\\\( \-name \"patches.\*\" \-o \-name \"audit.\*" \\\\) \-type f \-mtime +30 \-exec rm \-rf {} \\\\;'
    # serverspec expectations.
    # None: one still has to escape the backslashes
    xit { should have_entry '0 0 * * * /bin/find /tmp/repository/logs/ ! \\( -name "patches.*" -o -name "audit.*" \\) -type f -mtime +30 -exec rm -rf {} \\;' }
    it { should have_entry '0 0 * * * /bin/find /tmp/repository/logs/ ! \\\\( -name "patches.*" -o -name "audit.*" \\\\) -type f -mtime +30 -exec rm -rf {} \\\\;' }
  end
end