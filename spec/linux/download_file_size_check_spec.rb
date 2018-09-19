require 'spec_helper'

context 'File download size check examples' do

  local_file_path = '/opt/tomcat/current/webapps/ROOT.war'
  remote_file_path = "http://#{repo_server}/apps/ROOT.war"
  repo_server = 'localhost'
  # see also https://devhints.io/bash
  describe command(<<-EOF
    LOCAL_FILE_PATH='#{local_file_path}'
    REMOTE_FILE_PATH='#{remote_file_path}'
    SIZE_IN_DISK=$(stat -c '%s' '${LOCAL_FILE_PATH}');
    echo "Size in disk: ${SIZE_IN_DISK}"
    DOWNLOAD_SIZE=$(curl -# -I '$REMOTE_FILE_PATH' | sed -n 's/Content-Length: *//p' | sed 's/\\r//');
    echo "Download file size: ${DOWNLOAD_SIZE}"
    if [ $SIZE_IN_DISK != $DOWNLOAD_SIZE ] ; then
      echo 'size mismatch'
    else
      echo 'size OK'
    fi
  EOF
  ) do
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
    its(:stdout) { should match /size OK / }
  end
end