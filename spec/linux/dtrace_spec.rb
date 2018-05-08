require 'spec_helper'
# origin: https://github.com/joyent/lx-brand-image-tests/blob/master/spec/ubuntu-certified/dtrace_spec.rb

# Test DTrace commmands

# Print version
describe command('/native/usr/sbin/dtrace -V') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('dtrace: Sun D ') }
end

# List all probes
describe command('/native/usr/sbin/dtrace -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('PROVIDER') }
end

# List all probes provided by the syscall provider
describe command('/native/usr/sbin/dtrace -l -P syscall') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('PROVIDER') }
end

# Print all entry probes provided by the syscall provide
describe command('/native/usr/sbin/dtrace -l -n syscall:::entry') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('PROVIDER') }
end

# Various DTrace one liners
describe command('/native/usr/sbin/dtrace -n \'lx-syscall:::entry { @num[execname] = count(); } profile:::tick-1sec { exit(0); }\'') do
  its(:exit_status) { should eq 0 }
end

describe command('/native/usr/sbin/dtrace -n \'lx-syscall:::entry { @num[pid, execname, probefunc] = count(); } profile:::tick-1sec { exit(0); }\'') do
  its(:exit_status) { should eq 0 }
end

describe command('/native/usr/sbin/dtrace -n \'profile:::profile-1000hz { @Count[execname, pid] = lquantize(curlwpsinfo->pr_pri, 0, 170, 5); } profile:::tick-1sec { exit(0); }\'') do
  its(:exit_status) { should eq 0 }
end

describe command('/native/usr/sbin/dtrace -n \'proc:::exec-success { trace(curpsinfo->pr_psargs); } profile:::tick-1sec { exit(0); }\'') do
  its(:exit_status) { should eq 0 }
end

describe command('/native/usr/sbin/dtrace -n \'lx-syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); } profile:::tick-1sec { exit(0); }\'') do
  its(:exit_status) { should eq 0 }
end
