if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end

require 'socket'

context 'Tomcat Shutdown Test' do
  catalina_home = '/usr/share/tomcat'
  path_separator = ':'
  application = 'Tomcat Application Name'
  server_file_path = "#{catalina_home}/conf/server.xml"
  before(:each) do
    Specinfra::Runner::run_command(<<-EOF
      systemctl stop tomcat
      # configtest fails to initialize connector, ajp and shutdown ports with app s running
      #{catalina_home}/bin/configtest.sh
      systemctl start tomcat
      sleep 10
    EOF
    )
  end
  context 'Basic' do
    describe 'Ruby Call' do
      it 'should not get exception' do
        # NOTE: can not access instance #subject or #let methods without a block
        # NOTE: can not nest `describe` within `it`
        $stderr.puts subject
        begin
          TCPSocket.open('localhost', 8005) do |socket|
            socket.write('SHUTDOWN')
              # status = 0
          end
        rescue => e
          $stderr.puts 'Exception ' + e.to_s
          # status = 1
          throw
        end
      end
    end
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
              pw.println("SHUTDOWN"); //send shutdown command
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
# tomcat comes packaged into several rpm packages:
#
#  tomcat-admin-webapps.noarch
#  tomcat-docs-webapp.noarch
#  tomcat-javadoc.noarch
#  tomcat-jsp-2.2-api.noarch
#  tomcat-jsvc.noarch
#  tomcat-lib.noarch
#  tomcat-servlet-3.0-api.noarch
#  tomcat-webapps.noarch
#  tomcatjss.noarch
#  
# - it is possible to find oneself on centos system with tomcat installed and functional but some of the admin script absent
#
# To install tomcat 8.5.x i from archive on centos 7.x follow the
# https://www.vultr.com/docs/how-to-install-apache-tomcat-8-on-centos-7

# wget http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.33/bin/apache-tomcat-8.5.33.tar.gz
# sudo tar -zxvf apache-tomcat-8.5.33.tar.gz -C /usr/share/tomcat --strip-components=1
# sudo -s
# cd /usr/share/tomcat
# chgrp -R tomcat conf
# chmod g+rwx conf
# chmod g+r conf/*
# chown -R tomcat logs/ temp/ webapps/ work/
# chgrp -R tomcat bin/ lib/ logs/
# chmod g+rwx bin
# chmod g+r bin/*
# check readlink  `readlink \`which java\``
# vi /etc/systemd/system/tomcat.service

# [Unit]
# Description=Apache Tomcat Web Application Container
# After=syslog.target network.target
#
# [Service]
# Type=forking
#
# Environment=JAVA_HOME=/usr/lib/jvm/jre
# Environment=CATALINA_PID=/usr/share/tomcat/temp/tomcat.pid
# Environment=CATALINA_HOME=/usr/share/tomcat
# Environment=CATALINA_BASE=/usr/share/tomcat
# Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
# Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
#
# ExecStart=/usr/share/tomcat/bin/startup.sh
# ExecStop=/bin/kill -15 $MAINPID
#
# User=tomcat
# Group=tomcat
#
# [Install]
# WantedBy=multi-user.target
