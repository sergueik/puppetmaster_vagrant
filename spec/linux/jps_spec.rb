require 'spec_helper'

context 'java process list' do
  java_memory_opt =  {
   :initial => '512M',
   :max => '1024M'
  }
  describe command(<<-EOF
    jps -lv | grep -E '(DirectoryServer|Bootstrap)'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match Regexp.new(".* -Xmx#{java_memory_opt[:max]} .* ") }
    its(:stdout) { should match Regexp.new(".* -Xms#{java_memory_opt[:initial]} .*") }
    its(:exit_status) { should eq 0 }
  end
end
