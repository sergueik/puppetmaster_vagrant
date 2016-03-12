    context 'Repeated Run' do 
      lines = [ 
        'answer: 42',
        'Status: unchanged',
        '"failed"=>0', # resources
        '"failure"=>0', # events
      ]
      describe command(<<-EOF
        export RUBYOPT='rubygems'
        ruby #{script_file} --run=2
      EOF
      ) do
        # NOTE: Ruby may not be installed system-wide, need to add agent to the PATH 
        # Puppet 4.3 (2015.2) : `/opt/puppetlabs/bin`
        # Puppet 3.4 (Puppet Enterprise 3.2) `/opt/puppet/bin`: 
        let(:path) { '/opt/puppet/bin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/sbin:/bin:/usr/sbin:/usr/bin' } 
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
        lines.each do |line| 
          its(:stdout) do
            should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
          end
        end
      end
    end
    context 'First Run' do 
      lines = [ 
        'answer: 42',
        'Status: changed',
        '"failed"=>0', # resources
        '"failure"=>0', # events
      ]

      describe command(<<-EOF
        export RUBYOPT='rubygems'
        ruby #{script_file} --run=1
      EOF
      ) do
        # NOTE: Ruby may not be installed system-wide, need to add agent to the PATH 
        # Puppet 4.3 (2015.2) : `/opt/puppetlabs/bin`
        # Puppet 3.4 (Puppet Enterprise 3.2) `/opt/puppet/bin`: 
        let(:path) { '/opt/puppet/bin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/sbin:/bin:/usr/sbin:/usr/bin' } 
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
        lines.each do |line| 
          its(:stdout) do
            should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
          end
        end
      end
    end
