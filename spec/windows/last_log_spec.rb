require_relative '../windows_spec_helper'

context 'last_run_report' do
  statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'

  last_run_report = 'last_run_report.yaml'
  first_run_report = 'first_run_report.yaml'

  before(:all) do
    Specinfra::Runner::run_command(<<-END_COMMAND
    $statedir = '#{statedir}'
    $last_run_report = '#{last_run_report}'
    $first_run_report = '#{first_run_report}'
    $filename_mask = ('{0}.*' -f $last_run_report)
    pushd $statedir
    $run_reports = ( 
      Get-ChildItem -Name "$last_run_report.*" -ErrorAction 'Stop' | 
      sort-object -descending )
    $first_run = $run_reports[0]
    copy-item -path $first_run -destination $first_run_report -force
    popd
END_COMMAND
) end

  describe file("#{statedir}/#{first_run_report}") do
    resource_title = 'after_command1'
    it { should be_file }
    [
    "resource: Reboot[#{resource_title}]",
    'resource_type: Reboot'
    ].each do |line|
      it do
         should contain Regexp.new(line.gsub(']', '\]' ).gsub('[', '\[' ))
      end
    end
  end
end
