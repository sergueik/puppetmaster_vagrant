require 'spec_helper'

describe 'uru::run_serverspec' do

    before(:each) do
      Puppet.features.stubs(:microsoft_windows? => false, :posix? => true)
    end
    let(:title) { 'title' }
    let(:pre_condition) do
      <<-EOF
       class { 'staging':
        path      => '/usr/local/bin/usr/binc:/sbin',
        exec_path => '/opt/staging',
      }
      EOF
    end

    let(:facts) do
      {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.6',
      :kernel                 => 'linux'
      }
    end

    context 'Control Fow' do
      let(:params) do
        {
          :root            => '/scratch/uru',
          :covered_modules => ['uru'],
        }
      end
      it { should compile.with_all_deps  }
      it { should contain_file('reports directory').with('ensure' => 'absent', 'path' => '/scratch/uru/reports', 'recurse' => 'true') }
      it { should contain_file('Rakefile') }
      it { should contain_file('spec/spec_helper.rb') }
      it { should contain_file('spec') }
      it do
        should contain_file('spec/serverspec').with({'sourceselect' => 'all', 'path' => '/scratch/uru/spec/serverspec', 'recurse' => 'true'})
      end
      it { should contain_file('runner') }
      it { should contain_exec('runner').with('creates' => '/scratch/uru/reports/report_.json', 'refreshonly' => 'true') }
      it { should contain_file('reporter') }
      it { should contain_exec('reporter').with('subscribe' => "Exec[runner]", 'refreshonly' => 'true') }

    end
    context 'Collecting Modules' do

      context 'Role Based' do

        let(:params) do
          {
            :root            => '/scratch/uru',
            :covered_modules => ['will', 'be', 'ignored'],
            :server_role     => 'server_role_munged',
          }
        end
        it { should compile.with_all_deps  }
        it do
          should contain_file('spec/serverspec').with('source' => 'puppet:///modules/profile/serverspec/roles/server_role_munged')
        end

      end
      
      context 'Module Based' do

        let(:params) do
          {
            :root            => '/scratch/uru',
            :covered_modules => ['module1', 'module2'],
          }
        end
        it { should compile.with_all_deps  }
        it do
          should contain_file('spec/serverspec').with('source' => '["puppet:///modules/module1/serverspec/rhel", "puppet:///modules/module2/serverspec/rhel"]')
        end

      end
      context 'Spec Directories' do
        context 'RedHat 6.X' do
          let(:facts) do
            {
            :osfamily               => 'RedHat',
            :operatingsystemrelease => '6.6',
            :kernel                 => 'linux'
            }
          end
          let(:params) do
            {
              :root            => '/scratch/uru',
              :covered_modules => ['uru'],
            }
          end
          it { should compile.with_all_deps  }
          it do
            should contain_file('spec/serverspec').with('source' => '["puppet:///modules/uru/serverspec/rhel"]')
          end

        end
        context 'RedHat 7.X' do
          let(:facts) do
            {
            :osfamily               => 'RedHat',
            :operatingsystemrelease => '7.2',
            :kernel                 => 'linux'
            }
          end
          let(:params) do
            {
              :root            => '/scratch/uru',
              :covered_modules => ['covered_module'],
            }
          end
          osfamily_release = 'rhel_7'
          it { should compile.with_all_deps  }
          it do
            should contain_file('spec/serverspec').with('source' => "[\"puppet:///modules/covered_module/serverspec/#{osfamily_release}\", \"puppet:///modules/covered_module/serverspec/rhel\"]")
          end
        end
      end
    end
  at_exit { RSpec::Puppet::Coverage.report! }

end
