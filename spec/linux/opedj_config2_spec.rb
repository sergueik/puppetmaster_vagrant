require 'spec_helper'

context 'Opendj config' do
  # https://backstage.forgerock.com/docs/ds/5/configref/index.html?global.html
  state = 'true'
  entry_cache_name = 'Soft Reference'
  entry_cache_type = 'soft-reference'
  entry_cache_level = 2
  entry_cache_enabled = false
  entry_exclude_filter = '{objectClass=groupOfUniqueNames}'
  debug = true
  # mock dsconfig command output
  entry_list_datafile = '/tmp/entry_list.txt'
  entry_prop_datafile = '/tmp/entry_prop.txt'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{entry_list_datafile}
Entry Cache    : Type           : cache-level : enabled
---------------:----------------:-------------:--------
FIFO           : fifo           : 1           : false
#{entry_cache_name} : #{entry_cache_type} : #{entry_cache_level}           : #{entry_cache_enabled}
END
      cat <<END>#{entry_prop_datafile}
Property      : Value(s)
---------------:----------------:-------------:--------
cache-level    : #{entry_cache_level}
enabled        : #{entry_cache_enabled}
include-filter : -
exclude-filter : #{entry_exclude_filter}
END
  EOF
  )
  end
  describe command(<<-EOF
    cat '#{entry_list_datafile}' | awk -F: '/#{entry_cache_name}/ {if ($2 ~ /#{entry_cache_type}/ && $3 ~ /#{entry_cache_level}/ && $4 ~ /#{entry_cache_enabled}/ ) {print "Found \\"#{entry_cache_name}\\"" ; exit 0 } else {print "Different \\"#{entry_cache_name}\\"" ; exit 0 } }'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match /Found "#{entry_cache_name}"/ }
    # its(:stdout) { should match "Found #{port}" }
    its(:exit_status) { should eq 0 }
  end
end
