require 'spec_helper'

cronjob_user = 'cronjob_user'
port = '1873'
password_file = '/var/lib/rsync.secret'

# NOTE: there is no need to escape special characters
# https:/github.com/mizzy/specinfra/blob/master/lib/specinfra/command/base/cron.rb#L4
describe cron do
  its(:table) { should match  /\* \* \* \* \* ls \/tmp/ }
  it { should have_entry("*/5 * * * * /usr/bin/rsync -avz --delete --port #{port} --password-file=#{password_file} #{cronjob_user}@hostname.domain::deployment_repo/ deployment_repo").with_user(cronjob_user) }
  # NORE: Partial matches do not work because the underlying `check_has_entry` command enforces the full line match:
  # https:/github.com/mizzy/specinfra/blob/master/lib/specinfra/command/base/cron.rb#L5
  it { should_not have_entry( "*/5 * * * * /usr/bin/rsync -avz --delete --port #{port} --password-file=#{password_file}").with_user(user) }
  # RSpec 3.x syntax:
  it { expect(subject).to have_entry "*/5 * * * * /usr/bin/rsync -avz --delete --port #{port} --password-file=#{password_file}" }
end

# http:/serverspec.org/resource_types.html#cron says
# You can get all cron table entries and use regexp like this.
# Unfortunately does not work with another user, removed the expectation

describe command("/bin/crontab -u #{cronjob_user} -l") do
  [
    '# Puppet Name: wso2_deployment_sync',
    "*/5 * * * * /usr/bin/rsync -avz --delete --port #{port} --password-file=#{password_file} #{cronjob_user}@hostname.domain::deployment_repo/ deployment_repo",
    'find /opt/mule/logs/ -type f -mtime +30 -exec rm -rf {} \;',
  ].each do |line|
    {
      '\\' => '\\\\\\\\',
      '$'  => '\\\\$',
      '+'  => '\\\\+',
      '?'  => '\\\\?',
      '-'  => '\\\\-',
      '*'  => '\\\\*',
      '{'  => '\\\\{',
      '}'  => '\\\\}',
      '('  => '\\(',
      ')'  => '\\)',
      '['  => '\\[',
      ']'  => '\\]',
      ' '  => '\\s*',
    }.each do |s,r|
      line.gsub!(s,r)
    end
    its(:stdout) do
      should match(Regexp.new(line, Regexp::IGNORECASE))
    end
  end
end
