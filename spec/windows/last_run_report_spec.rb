require_relative '../windows_spec_helper'

# This example inspects the Puppet Last Run report on the instance
context 'Confirm Reboot During Pupppet Run' do
  statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  last_run_report = 'last_run_report.yaml'
  earlier_run_report = 'last_run_report.yaml.1'

  before(:all) do
    Specinfra::Runner::run_command( <<-EOF
      $statedir = '#{statedir}'
      $last_run_report = '#{last_run_report}'
      $earlier_run_report = '#{earlier_run_report}'
      $filename_mask = ('{0}.*' -f $last_run_report)
      pushd $statedir
      $run_reports = (Get-ChildItem -Name "$last_run_report.*" -ErrorAction 'Stop' |  sort-object -descending )
      $earlier_run = $run_reports[0]
      copy-item -path $earlier_run -destination $earlier_run_report -force
      # NOTE: policies with more than one reboot per provisioning may vary.
      popd
  EOF
  ) end

  describe file("#{statedir}/#{earlier_run_report}") do
    resource_title = '<known command that should have triggered the reboot>'
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

# This example creates a command to access the Puppet Last Run report on the instance
