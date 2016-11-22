if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'uru' do
  uru_home = 'c:/uru'
  user_home = ENV.has_key?('VAGRANT_EXECUTABLE') ? 'c:/users/vagrant' : ( 'c:/users/' + ENV['USER'] )
  gem_version = '2.1.0'
  before(:all) do
      begin
        Specinfra::Runner::run_command(<<-EOF
          write-output 'TODO'
        EOF
        )
      rescue
        # undefined method `metadata' for nil:NilClass
      end
  end

  before(:all) do
    require 'win32/registry'
    Win32::Registry::HKEY_CURRENT_USER.open('Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN') do |reg|
      # Suppress the internet Explorer dialog 'allow active content to run in files on my computer'
      begin
        reg.write('iexplore.exe', Win32::Registry::REG_DWORD, '0')
      rescue
        # Access is denied.
      end
    end
  end
  context 'Path' do
    describe command(<<-EOF
      pushd env:
      dir 'PATH' | format-list
      popd
      EOF
    ), :if => ENV.has_key?('URU_INVOKER') do
      its(:stdout) { should match Regexp.new(
        '_U1_;' +
        uru_home.gsub('/','[/|\\\\\\\\]') +
        '\\\\ruby\\\\bin' +
        ';_U2_',
        Regexp::IGNORECASE)
        }
    end
  end

  context 'Directories' do
    [
      uru_home,
      "#{user_home}/.uru",
     ].each do |directory|
      describe file(directory) do
        it { should be_directory }
      end
    end
    describe file("#{user_home}/.uru/rubies.json") do
      it { should be_file }
    end
  end
  context 'Runners' do
    %w|
        uru_rt.exe
        runner.ps1
        processor.ps1
        processor.rb
      |.each do |file|
      describe file("#{uru_home}/#{file}") do
        it { should be_file }
      end
    end
  end
  context 'Running Ruby commands' do
    describe command(<<-EOF
      where.exe ruby
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should be_empty }
      its(:stdout) do
        should match( Regexp.new(uru_home.gsub('/','[/|\\\\\\\\]') +
          '\\\\ruby\\\\bin\\\\ruby.exe', Regexp::IGNORECASE))  
      end
    end
  end
  require 'type/property_file'

  context 'Custom Type' do
    property_file_path = "#{user_home}/sample.properties"
    describe property_file(property_file_path) do
      it { should have_property('package.class.property', 'value' ) }
    end
  end
end