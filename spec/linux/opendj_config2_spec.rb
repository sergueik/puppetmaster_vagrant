require 'spec_helper'

context 'Advanced opendj config' do
  # This serverspec exercises one-liner commands used for Puppet to deal with opendj application configuration
  # https://backstage.forgerock.com/docs/ds/5/configref/index.html?global.html
  # where often a multi property objects (backends, indexes, etc.) are created or removed
  # and properties or existing objects are changed
  # based on intelligent presence checks
  # A frequent alterative of creating a file on the target node which contents is
  # a hash of the hieradata describing the target object is not very flexible
  # Testing such snippet in real provision is inefficient, with some part of runs failing due to
  # inevitable errors in the shell scripts serving as "unless" and "onlyif" conditons to Puppet exec resources
  entry_cache_name = 'Soft Reference'
  entry_cache_type = 'soft-reference'
  entry_cache_level = 2
  entry_cache_enabled = false
  entry_exclude_filter = '{objectClass=groupOfUniqueNames}'
  entry_include_filter = '-'
  debug = true
  backend_index_name = 'uniqueMember'
  backend_index_type = 'equality'
  backend_index_entry_limit = 5000

  # mock dsconfig command output
  entry_list_datafile = '/tmp/entry_list.txt'
  entry_prop_datafile = '/tmp/entry_prop.txt'
  backend_index_list_datafile = '/tmp/backend_index_list.txt'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
    # mocking the dsconfig list-entry-caches command
      cat <<END>#{entry_list_datafile}
Entry Cache         : Type                : cache-level          : enabled
--------------------:---------------------:----------------------:--------
FIFO                : fifo                : 1                    : false
#{entry_cache_name} : #{entry_cache_type} : #{entry_cache_level} : #{entry_cache_enabled}
END
      # mocking the dsconfig get-entry-cache-prop command
      cat <<END>#{entry_prop_datafile}
Property       : Value(s)
---------------:----------------:-------------:--------
cache-level    : #{entry_cache_level}
enabled        : #{entry_cache_enabled}
include-filter : -
exclude-filter : #{entry_exclude_filter}
END
    # mocking the dsconfig list-backend-indexes command
      cat <<END>#{backend_index_list_datafile}
Backend Index         : index-type        : index-entry-limit            : index-extended-matching-rule : confidentiality-enabled
----------------------:-------------------:------------------------------:------------------------------:-------------------------
#{backend_index_name} : #{backend_index_type} : #{backend_index_entry_limit} : -                            : false
END
  EOF
  )
  end
  describe command(<<-EOF
    cat '#{entry_list_datafile}' | grep -Eq '^#{entry_cache_name}\\b'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should be_empty }
    its(:exit_status) { should eq 0 }
  end
  # NOTE: the exit status of 1 for "found exact match" to have
  # with the same exit code for both
  # "not found" and "found poor match"
  describe command(<<-EOF
    cat '#{entry_list_datafile}' | awk -F: '/#{entry_cache_name}/ {if ($2 ~ /#{entry_cache_type}/ && $3 ~ /#{entry_cache_level}/ && $4 ~ /#{entry_cache_enabled}/ ) {print "Found \\"#{entry_cache_name}\\"" ; exit 1 } else {print "The object \\"#{entry_cache_name}\\" is different" ; exit 0 } }'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match /Found "#{entry_cache_name}"/ }
    its(:exit_status) { should eq 1 }
  end
  property_names = [
    'cache-level',
    'enabled',
    'include-filter',
    'exclude-filter'
  ]
  property_values = [
    false,
    2,
    '-',
    '{objectClass=groupOfUniqueNames}'
  ]
  property_names_search = '(' + property_names.join('|') + ')'
  property_values_search = '(' + property_values.join('|') + ')'
  # NOTE this snippet would not be a good candidate for unless condition - does not verify much on its own
  describe command(<<-EOF
    cat '#{entry_prop_datafile}' | awk -e 'BEGIN { status = 0 } /#{property_names_search}/ {print $3 > "/dev/stderr" ; status = status + 1} END { print "Status: " status }'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match /Status: #{property_names.length}/ }
    its(:stderr) { should match /(soft-reference|Soft Reference|{objectClass=groupOfUniqueNames})/ }
    its(:exit_status) { should eq 0 } # NOTE exit status
  end

  describe command(<<-EOF
    cat '#{entry_prop_datafile}' | awk -e '/#{property_names_search}/ {if ($3 ~ /#{entry_exclude_filter}/ || $3 ~ /#{entry_include_filter}/ ||$3 ~ /#{entry_cache_level}/ || $3 ~ /#{entry_cache_enabled}/ ) found[$1] = $3;} END { for (key in found ) print found[key] > "/dev/stderr"; print "Found: " length(found);}'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match /Found: #{property_names.length}/ }
    its(:stderr) { should match /(false|2|-|{objectClass=groupOfUniqueNames})/ }
    its(:exit_status) { should eq 0 }
  end

  # NOTE: the exit status of 1 for "found exact match" to have
  # with the same exit code for both
  # "not found" and "found poor match"
  describe command(<<-EOF
    cat '#{entry_prop_datafile}' | awk -e 'BEGIN { matched_field_count = 0 } /#{property_names_search}/ {if ($3 ~ /#{entry_exclude_filter}/ || $3 ~ /#{entry_include_filter}/ ||$3 ~ /#{entry_cache_level}/ || $3 ~ /#{entry_cache_enabled}/ ) { print $3 > "/dev/stderr"; matched_field_count = matched_field_count + 1; }} END { if (matched_field_count == 4 ) {print "Found \\"#{entry_cache_name}\\"" ; exit 1 } else {print "The object \\"#{entry_cache_name}\\" is different" ; exit 0 } }'
  EOF
  ) do
    let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
    its(:stdout) { should match /Found "#{entry_cache_name}"/ }
    its(:stderr) { should match /(false|2|-|{objectClass=groupOfUniqueNames})/ }
    its(:exit_status) { should eq 1 }
  end
end
