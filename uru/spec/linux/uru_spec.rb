context 'uru' do
  uru_home = '/uru'
  gem_version = '2.1.0'
  user_home = '/root'
  context 'Path' do
    describe command('echo $PATH'), :if => ENV.has_key?('URU_INVOKER') do
      its(:stdout) { should match Regexp.new("_U1_:#{user_home}/.gem/ruby/#{gem_version}/bin:#{uru_home}/ruby/bin:_U2_:") }
    end
  end
  context 'Directories' do
    [
      uru_home,
      "#{user_home}/.uru",
      "#{user_home}/.gem/ruby/#{gem_version}",
    ].each do |directory|
      describe file(directory) do
        it { should be_directory }
      end
    end
    describe file("#{user_home}/.uru/rubies.json") do
      it { should be_file }
    ends
  end
  context 'Runners' do
    %w|
        uru_rt
        runner.sh
        processor.rb
      |.each do |file|
      describe file("#{uru_home}/#{file}") do
        it { should be_file }
        it { should be_mode(755) }
      end
    end
  end
end