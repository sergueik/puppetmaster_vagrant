require 'spec_helper'

context 'Shell Scripts' do

  content 'custom script' do
    # Testing
    # p="file{ '/tmp/mysql_dump.sh': ensure => file, owner => 'root', group => 'root', mode => '0755', content => 'find /apps/mysql_dump/ ! -name mysql_dump.sh -mtime +7 -exec rm {} \; ; /bin/mysqldump -A > /apps/mysql_dump/mysql-\`date +%F\`.sql ; gzip -f /apps/mysql_dump/mysql-\`date +%F\`.sql', }"
    # puppet apply -e "$p"
    #
    shell_script = '/tmp/mysql_dump.sh'
    # Regexp.escape does not work right. Need to use literal
    # shell_script_contents = Regexp.escape('find /apps/mysql_dump/ ! -name mysql_dump.sh -mtime +7 -exec rm {} \; ; /bin/mysqldump -A > /apps/mysql_dump/mysql-`date +%F`.sql ; gzip -f /apps/mysql_dump/mysql-`date +%F`.sql')
    describe file(shell_script) do

      [
        'find /apps/mysql_dump/ ! -name mysql_dump.sh -mtime +7 -exec rm {} \; ; /bin/mysqldump -A > /apps/mysql_dump/mysql-`date +%F`.sql ; gzip -f /apps/mysql_dump/mysql-`date +%F`.sql',
        # when the shell script content expectation fails can also break long command into shorter chunks
        'find /apps/mysql_dump/ ',
        '! -name mysql_dump.sh',
        '-mtime +7 -exec rm {} \; ;',
        '/bin/mysqldump -A > /apps/mysql_dump/mysql-`date +%F`.sql ;',
        'gzip -f /apps/mysql_dump/mysql-`date +%F`.sql',
      ].each do |line|
        {
          '\\' => '\\\\\\\\',
          '$' => '\\\\$',
          '+' => '\\\\+',
          '?' => '\\\\?',
          '-' => '\\\\-',
          '*' => '\\\\*',
          '{' => '\\\\{',
          '}' => '\\\\}',
          '(' => '\\(',
          ')' => '\\)',
          '[' => '\\[',
          ']' => '\\]',
          ' ' => '\\s*',
        }.each do |s,r|
          line.gsub!(s,r)
        end
        its(:content) do
          should match(Regexp.new(line, Regexp::IGNORECASE))
        end
      end
      it { should contain('find /apps/mysql_dump/ ! -name mysql_dump.sh -mtime +7 -exec rm {} \; ; /bin/mysqldump -A > /apps/mysql_dump/mysql-`date +%F`.sql ; gzip -f /apps/mysql_dump/mysql-`date +%F`.sql') }
    end
  end
  context 'cron job' do
    cronjob_script = '/etc/cron.daily/logrotate'
    describe file(cronjob_script) do
      [
        '#!/bin/sh',
        '# THIS FILE IS AUTOMATICALLY DISTRIBUTED BY PUPPET.  ANY CHANGES WILL BE',
        '# OVERWRITTEN.',
        '',
        'OUTPUT=$(/usr/sbin/logrotate /etc/logrotate.conf 2>&1)',
        'EXITVALUE=$?',
        'if [ $EXITVALUE != 0 ]; then',
        '/usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"',
        'echo "${OUTPUT}"',
        'fi',
        'exit $EXITVALUE',
      ].each do |line|
        # NOTE: contain needs verbatim match
        # and is unreliable
        # it { should contain(line) }
        {
          '\\' => '\\\\\\\\',
          '$' => '\\\\$',
          '+' => '\\\\+',
          '?' => '\\\\?',
          '-' => '\\\\-',
          '*' => '\\\\*',
          '{' => '\\\\{',
          '}' => '\\\\}',
          '(' => '\\(',
          ')' => '\\)',
          '[' => '\\[',
          ']' => '\\]',
          ' ' => '\\s*',
        }.each do |s,r|
          line.gsub!(s,r)
        end
        its(:content) do
          should match(Regexp.new(line, Regexp::IGNORECASE))
        end
      end
    end
  end
end
