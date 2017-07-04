module Serverspec::Type
  # redefine https://github.com/mizzy/serverspec/blob/master/lib/serverspec/type/cron.rb
  class Cron < Base
    def has_entry?(user, entry)
      @runner.check_cron_has_entry(user, entry)
    end

    def table(user = nil)
      @runner.get_cron_table(user).stdout
    end

    def to_s
      'Cron'
    end
  end
end

# static override of https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/base/cron.rb

Specinfra::Command::Base::Cron.class_eval do
  def self.check_has_entry(user, entry)
    entry_alt = entry
    {
      /\\/ => '\\\\\\\\',
      /\$/ => '\\\\$',
      /\+/ => '\\\\+',
      /\?/ => '\\\\?',
      /\-/ => '\\\\-',
      /\*/ => '\\\\*',
      /\{/ => '\\\\{',
      /\}/ => '\\\\}',
      /\(/ => '\\(',
      /\)/ => '\\)',
      /\[/ => '\\[',
      /\]/ => '\\]',
      ' '  => ' *',
    }.each do |s,r|
      # NOTE: in-place update appears to corrupt the original entry
      # entry_alt.gsub!(s,r)
      entry_alt = entry_alt.gsub(s,r)
    end
    # STDERR.puts entry_alt
    # grep_command = "grep -v '^[[:space:]]*#' | grep -- ^#{entry_alt}"
    # /bin/sh -c crontab\ -l\ \|\ grep\ -v\ \'\^\[\[:space:\]\]\*\#\'\ \|\ grep\ --\ \^0\ \*0\ \*\\\*\ \*\\\*\ \*\\\*\ \*/etc/cron.daily/script

    entry_escaped = entry.gsub(/\\/, '\\\\\\').gsub(/\*/, '\\*').gsub(/\[/, '\\[').gsub(/\]/, '\\]')
    # NOTE:  removed the trailing '$'
    grep_command = "grep -v '^[[:space:]]*#' | grep -- ^#{escape(entry_escaped)}"
    # /bin/sh -c crontab\ -l\ \|\ grep\ -v\ \'\^\[\[:space:\]\]\*\#\'\ \|\ grep\ --\ \^0\\\ 0\\\ \\\\\\\*\\\ \\\\\\\*\\\ \\\\\\\*\\\ /etc/cron.daily/script
    if user.nil?
      "crontab -l | #{grep_command}"
    else
      "crontab -u #{escape(user)} -l | #{grep_command}"
    end
  end

  def self.get_table(user = nil)
    if user.nil?
      'crontab -l'
    else
      "crontab -u #{escape(user)} -l"
    end
  end
end
