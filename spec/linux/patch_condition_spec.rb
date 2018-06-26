require 'spec_helper'


# e.g. Forgerock
# https://backstage.forgerock.com/knowledge/kb/article/a62478933
# recommends checkingthe Build of their product to determine if a certain patch is needed or not 

context 'OpenDJ Patch Version' do

  patch_release = '20180625215341'
  # The below command was actually used in an onlyif condition in a custom exec resource for emergeny patch
  # NOTE: 
  # expr arg1 \< arg2 
  # displays 1 but has exit status 0 when alg1 is less than arg2
  # and vice versa
  # https://linux.101hacks.com/unix/expr
  describe command(<<-EOF
    pushd /opt/opendj/bin
    REQUIRED_PATCH_RELEASE='#{patch_release}'
    PARTIAL_RELEASE=$(echo $REQUIRED_PATCH_RELEASE | egrep -o '[[:digit:]]{3}' | head -n1) # 201
    CURRENT_PATCH_RELEASE=$(./status -V |grep 'Build'| grep "${PARTIAL_RELEASE}" | awk '{print #2}')
    expr $CURRENT_PATCH_RELEASE \\< $REQUIRED_PATCH_RELEASE
  EOF
  ) do
    # after Puppet apply the release is equal to patch_release
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match '1' }
  end
end