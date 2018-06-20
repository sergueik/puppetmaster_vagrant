if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end

context 'Tomcat Shutdown Test' do
  before(:all) do
    Specinfra::Runner::run_command('systemctl start tomcat; sleep 10')
  end
  catalina_home = '/opt/tomcat'
  path_separator = ':'
  application = 'Tomcat Application Name'
  jdbc_path = "#{catalina_home}/webapps/#{application}/WEB-INF/lib/"
  config_file_path = "#{catalina_home}/conf/context.xml"
  #
  class_name = 'ShutdownTest'
  sourcfile = "#{class_name}.java"
  source = <<-EOF
    import java.io.BufferedReader;
    import java.io.IOException;
    import java.io.InputStreamReader;
    import java.io.OutputStream;
    import java.io.PrintWriter;
    import java.net.Socket;

    public class ShutdownTest {

      public static void main(String[] args){
        try {
          Socket socket = new Socket("localhost", 8005);
          if (socket.isConnected()) {
            PrintWriter pw = new PrintWriter(socket.getOutputStream(), true);
            pw.println("SHUTDOWN");//send shut down command
            pw.close();
            socket.close();
          }
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  EOF
  describe command(<<-EOF
    >/dev/null pushd /tmp
    echo '#{source}' > '#{sourcfile}'
    >/dev/null javac '#{sourcfile}'
    java -cp . '#{class_name}'
    >/dev/null popd
  EOF
  ) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should be_empty }
    its(:stderr) { should_not contain 'Connection refused' }
  end
end
