require 'spec_helper'

context 'Artifact deployment' do

  # Verifies that the jars (apache commons, jdbc and the like) are updated in
  # catalina lib directory from the controled repo
  # that is known to the instance via the custom Puppet fact

  catalina_home = '/apps/tomcat/current'
  fact_name = 'baas_base_url'
  artifact_url = 'packages/tomcat'
  debug = false
  debug = true
  [
    'mysql-connector-java-6.0.4.jar',
    'commons-lang-2.6.jar',
  ].each do |jar_filename|

    describe command(<<-EOF
      JAR_FILENAME='#{jar_filename}'
      CATALINA_HOME='#{catalina_home}'
      FACT_NAME='#{fact_name}'
      ARTIFACT_URL='#{artifact_url}'
      DEBUG=#{debug}
      # for debugging
      if $DEBUG ; then
        ls -l $CATALINA_HOME/lib/$JAR_FILENAME
        stat $CATALINA_HOME/lib/$JAR_FILENAME
        echo curl -k -I $(facter $FACT_NAME)/$ARTIFACT_URL/$JAR_FILENAME\\| sed -n 's/Content-Length: \\([0-9][0-9]*\\)/\\1/p'
        curl -k -I $(facter $FACT_NAME)/$ARTIFACT_URL/$JAR_FILENAME| sed -n 's/Content-Length: \\([0-9][0-9]*\\)/\\1/p'
      fi
      TARGET_SIZE=$(stat $CATALINA_HOME/lib/$JAR_FILENAME | sed -n  's/Size: \\([0-9][0-9]*\\)  *.*$/\\1/p')
      SOURCE_SIZE=$(curl -k -I $(facter $FACT_NAME)/$ARTIFACT_URL/$JAR_FILENAME| sed -n 's/Content-Length: \\([0-9][0-9]*\\)/\\1/p')
      if $DEBUG ; then
        echo "Source size: '${SOURCE_SIZE}'"
        echo "Target size: '${TARGET_SIZE}'"
      fi
      if [[ $(expr $SOURCE_SIZE - $TARGET_SIZE) -ne '0' ]] ; then
        echo Artifact size mismatch for $JAR_FILENAME
        exit 1
      else
        echo Verified $JAR_FILENAME
        exit 0
      fi
      EOF
    ) do
      its(:stdout) { should match /Verified #{jar_filename}/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
