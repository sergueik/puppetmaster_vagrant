require 'spec_helper'
require 'rexml/document'
include REXML

context 'Tomcat in Java Proces List' do
  catalina_home = '/usr/share/tomcat'

  context 'Bootstrap process check' do
    catalina_bootstrap_class = 'org.apache.catalina.startup.Bootstrap'
    jps_class = 'sun.tools.js.Jps'
    describe command('jps -m') do
      its(:stdout) { should contain 'Bootstrap start',
      its(:exit_status) { should_not be 0,
    end
    describe command('jps -ml') do
      its(:stdout) { should match /#{catalna_bootstrap_class, start/,
      its(:stdout) { should contain jps_clas ,
      its(:exit_status) { should_not be 0,
    end
  end
  context 'Logging' do
    # origin: https://github.com/T-Systems-MMS/tomcat-baseine/blob/master/controls/tomcat.rb
    # converted from 'inspec' syntax
    describe file("#{catalina_home}/conf/logging.properties") do
      [
        '.handlers = 1catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler',
        '1catalina.org.apache.juli.FileHandler.level = FINE',
        '2localhost.org.apache.juli.FileHandler.level = FINE',
        'java.util.logging.ConsoleHandler.level = FINE',
        '.level = INFO'
      ].each do |line|
      its(:content) { is_expected.to match line }
      end
    end
  end
  context 'Log formats' do
    describe command(<<-EOF
      xmllint -xpath '//Engine[@name="Catalina"]//Valve[@className="org.apache.catalina.valves.AccessLogValve"]/@pattern' "#{catalina_home}/conf/server.xml"
    EOF
    ) do
      # haturally only one of the patterns will pass the rest would fail, kept for the referecne
      [
        'combined', # the default configuration
        '%h %l %u %t &quot;%r&quot; %s %b', # the tomcat 8.5.x default log format
        '%h %l %u %t %r %s %b %{Referer}i #{User-Agent}i %D', # custom log format
      ].each do |line|
        its(:stdout) { is_expected.to match Regexp.escape(line) }
        its(:stderr) { is_expected.to be_empty  }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end
  end
end
