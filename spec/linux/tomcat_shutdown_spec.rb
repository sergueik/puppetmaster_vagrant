if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end

context 'Tomcat Shutdown Test' do
  before(:all) do
    Specinfra::Runner::run_command('systemctl start tomcat; sleep 10')
  end
  catalina_home = '/usr/share/tomcat'
  path_separator = ':'
  application = 'Tomcat Application Name'
  server_file_path = "#{catalina_home}/conf/server.xml"
  context 'Basic' do
    #
    class_name = 'ShutdownTest'
    sourcfile = "#{class_name}.java"
    source = <<-EOF
      import java.net.Socket;
      import java.io.OutputStream;
      import java.io.PrintWriter;

      public class #{class_name} {

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
  context 'Using tomcat server.xml' do
    #
    class_name = 'ShutdownWithConfigReadTest'
    sourcfile = "#{class_name}.java"
    source = <<-EOF
      import java.net.Socket;

      import java.io.File;
      import java.io.FileInputStream;
      import java.io.IOException;
      import javax.xml.parsers.DocumentBuilderFactory;
      import javax.xml.parsers.ParserConfigurationException;
      import javax.xml.parsers.DocumentBuilder;
      import javax.xml.xpath.XPath;
      import javax.xml.xpath.XPathConstants;
      import javax.xml.xpath.XPathExpressionException;
      import javax.xml.xpath.XPathFactory;

      import org.w3c.dom.Document;
      import org.w3c.dom.Element;
      import org.xml.sax.SAXException;

      import java.io.OutputStream;
      import java.io.PrintWriter;

      public class #{class_name} {

        public static void main(String[] args){
          String serverFilePath = "#{server_file_path}";

          try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setIgnoringComments(true);
            factory.setCoalescing(true); // convert CDATA to Text nodes
            factory.setNamespaceAware(false); // no namespaces: this is default
            factory.setValidating(false); // do not validate DTD: also default

            DocumentBuilder parser = factory.newDocumentBuilder();
            Document document = parser.parse(new FileInputStream(new File(serverFilePath)));
            XPath xpath = (XPathFactory.newInstance()).newXPath();
            String xpathLocator = "/Server[@shutdown]";
            System.err.println(String.format("Looking for \\"%s\\"", xpathLocator));
            Element shutdownPortElement = (Element) xpath.evaluate(xpathLocator, document,
                XPathConstants.NODE);
            String shutdownPort = shutdownPortElement.getAttribute("port");
            String shutdownCommand = shutdownPortElement.getAttribute("shutdown");
            System.err.println(String.format("Sending the shutdown command \\"%s\\" to port \\"%s\\"",
              shutdownCommand, shutdownPort));
            Socket socket = new Socket("localhost",  Integer.parseInt(shutdownPort));
            if (socket.isConnected()) {
              PrintWriter pw = new PrintWriter(socket.getOutputStream(), true);
              pw.println(shutdownCommand);//send shut down command
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
end
