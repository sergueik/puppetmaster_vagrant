if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'uru' do
  uru_home = 'c:/uru'
  user_home = 'c:/users/vagrant'
  gem_version = '2.1.0'
  context 'Path' do
    describe command(<<-EOF
      pushd env:
      dir 'PATH' | format-list
      popd
      EOF
    ), :if => ENV.has_key?('URU_INVOKER') do
      its(:stdout) { should match Regexp.new('_U1_;' + uru_home.gsub('/','[/|\\\\\\\\]') + '\\\\ruby\\\\bin' + ';_U2_', Regexp::IGNORECASE) }
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
end