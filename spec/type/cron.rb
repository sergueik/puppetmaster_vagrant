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
    {
      /\\/ => '\\\\\\\\',
      /\$/ => '\\\\$',
      /\?/ => '\\\\?',
      /\-/ => '\\\\-',
      /\*/ => '\\\\*',
      /"/  => '\\\\"',
  #    /\+/ => '\\\\+',
  #    /\{/ => '\\\\{',
  #    /\}/ => '\\\\}',
  #    /\(/ => '\\(',
  #    /\)/ => '\\)',
  #    /\[/ => '\\[',
  #    /\]/ => '\\]',
      ' '  => ' *',
    }.each do |s,r|
      entry.gsub!(s,r)
    end
    # STDERR.puts '---'
    # STDERR.puts  entry
    # STDERR.puts '---'
    if user.nil?
      "crontab -l | grep '#{entry}'"
    else
      "crontab -u #{escape(user)} -l | grep '#{entry}'"
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
