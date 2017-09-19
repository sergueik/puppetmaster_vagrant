# NOTE: this logic not correct under uru
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end

context 'JDBC tests' do
  context 'Oracle' do
    context 'Using tomcat context.xml' do
      # <Resource
      #    name="jdbc/<entity>"
      #    auth="Container"
      #    type="javax.sql.DataSource"
      #    driverClassName="oracle.jdbc.OracleDriver"
      #    url="jdbc:oracle:thin:<username>/<password>@hostname:port/sid"
      #    factory="org.apache.tomcat.dbcp.dbcp.BasicDataSourceFactory"
      # />

      jdbc_driver_class_name = 'oracle.jdbc.driver.OracleDriver'
      class_name = 'TestConnectionWithCredentialsInUrl'
      database_query = 'SELECT DUMMY FROM dual'
      jars = ['ojdbc7.jar']
      jdbc_path = "#{catalina_home}/webapps/cd_upload/WEB-INF/lib/"
      path_separator = ':'
      jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(path_separator)
      entity = 'confluence'
      config_file_path = "#{catalina_home}/conf/context.xml"
      sourcfile = "#{class_name}.java"
      source = <<-EOF

        import java.io.File;

        import java.io.FileInputStream;
        import java.io.IOException;

        import javax.xml.parsers.DocumentBuilder;
        import javax.xml.parsers.DocumentBuilderFactory;
        import javax.xml.parsers.ParserConfigurationException;
        import javax.xml.xpath.XPath;
        import javax.xml.xpath.XPathConstants;
        import javax.xml.xpath.XPathExpressionException;
        import javax.xml.xpath.XPathFactory;
        import org.w3c.dom.Document;
        import org.w3c.dom.Element;
        import org.xml.sax.SAXException;
        import java.sql.Connection;
        import java.sql.DriverManager;
        import java.sql.ResultSet;
        import java.sql.Statement;
        import java.sql.SQLException;

        public class #{class_name} {

          public static void main(String[] args)
              throws SAXException, IOException, ParserConfigurationException,
              XPathExpressionException, ClassNotFoundException, SQLException {
            String tableName = "#{table_name}";
            DocumentBuilder db = (DocumentBuilderFactory.newInstance())
                .newDocumentBuilder();
            String configFilePath = "#{config_file_path}";
            Document document = db.parse(new FileInputStream(new File(configFilePath)));
            XPath xpath = (XPathFactory.newInstance()).newXPath();
            String entity = "#{entity}";
            String xpathLocator = String
                .format("/Context/Resource[ @name = \\"jdbc/%s\\"]", entity);
            System.err.println(String.format("Looking for \\"%s\\"", xpathLocator));
            Element userElement = (Element) xpath.evaluate(xpathLocator, document,
                XPathConstants.NODE);
            String username = userElement.getAttribute("username");
            String password = userElement.getAttribute("password");
            Class.forName("#{jdbc_driver_class_name}");

            String url = userElement.getAttribute("url");
            Connection connection = null;
            if (username == null || username.isEmpty()) {
              System.err.println(String.format("Connecting to %s", url));
              connection = DriverManager.getConnection(url);
            } else {
              System.err.println(String.format("Connecting to %s as \\"%s\\"/\\"%s\\"", url,
                  username, password));
              connection = DriverManager.getConnection(url, username, password);
            }

            Statement statement = connection.createStatement();
            String query = "#{database_query}";

            ResultSet m_ResultSet = statement.executeQuery(query);

            while (m_ResultSet.next()) {
              System.out.println(m_ResultSet.getString(1));
            }
          }
        }
      EOF
      describe command(<<-EOF
        pushd /tmp
        echo '#{source}' > '#{sourcfile}'
        javac '#{sourcfile}'
        java -cp #{jars_cp}:. '#{class_name}'
        popd
      EOF
      ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain 'X' }
      end
    end
      # based on:
      # http://www.java2s.com/Tutorial/Java/0340__Database/ConnectwithOraclesJDBCThinDriver.htm
      # https://confluence.atlassian.com/doc/configuring-an-oracle-datasource-in-apache-tomcat-339739363.html
    context 'Passing connection parameters directly' do
      jdbc_prefix = 'oracle:thin'
      jdbc_host = 'localhost'
      port_number = 3203
      jdbc_driver_class_name = 'oracle.jdbc.driver.OracleDriver'
      application = 'Tomcat Application Name'
      jdbc_path = "/opt/tomcat/webapps/#{application}/WEB-INF/lib"
      jars = ['ojdbc7.jar']
      path_separator = ':'
      jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(path_separator)
      database_host = 'localhost'
      database_query = 'SELECT DUMMY FROM dual'
      sid_name = 'sid'
      username = 'root'
      password = 'password'
      class_name = 'TestWithUserPassword'
      sourcfile = "#{class_name}.java"
      source = <<-EOF

        import java.sql.Connection;
        import java.sql.DriverManager;
        import java.sql.ResultSet;
        import java.sql.Statement;

        public class #{class_name} {

          public static void main(String[] args) throws Exception {
            Connection connection = getConnection();
            Statement statement = connection.createStatement();
            String query = "#{database_query}";
            ResultSet resultSet = statement.executeQuery(query);
            while (resultSet.next()) {
              System.out.println(resultSet.getString(1));
            }
            resultSet.close();
            statement.close();
            connection.close();
          }

          private static Connection getConnection() throws Exception {
            String driver = "#{jdbc_driver_class_name}";
            try {
              Class.forName(driver);
            } catch (Exception e) {
              System.out.println("Exception: " + e.getMessage());
            }
            String databaseHost = "#{database_host}";
            int portNumber = #{port_number};
            String sidName = "#{sid_name}";
            String url = "jdbc:#{jdbc_prefix}:@//" + databaseHost + ":" + portNumber + "/"
                + sidName;
            String username = "#{username}";
            String password = "#{password}";
            return DriverManager.getConnection(url, username, password);
          }
        }
      EOF
      describe command(<<-EOF
        pushd /tmp
        echo '#{source}' > '#{sourcfile}'
        javac '#{sourcfile}'
        java -cp #{jars_cp}:. '#{class_name}'
        popd
      EOF
      ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain 'X' }
        its(:stderr) { should be_empty }
      end
    end
  end
  context 'MS SQL' do
    catalina_home = '/apps/tomcat/7.0.77'
    jdbc_prefix = 'microsoft:sqlserver'
    application = 'Tomcat Application Name'
    jdbc_path = "/opt/tomcat/webapps/#{application}/WEB-INF/lib"
    jars = ['sqljdbc41.jar','sqljdbc42.jar', 'sqljdbc_6.0']
    jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(':')
    context 'Using tomcat context.xml' do
      # based on:
      # https://stackoverflow.com/questions/25259836/how-to-get-attribute-value-using-xpath-in-java
      # http://www.java2s.com/Code/Java/Development-Class/CommandLineParser.htm
      # http://www.java2s.com/Code/Java/Database-SQL-JDBC/Connecttoadatabaseandreadfromtable.htm

      # <Resource name="jdbc/database_name"
      #    auth="Container"
      #    factory="org.apache.tomcat.dbcp.dbcp.BasicDataSourceFactory"
      #    driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
      #    type="javax.sql.DataSource"
      #    username = "<username>"
      #    password = "<password>"
      #    url="jdbc:sqlserver://database_host;databaseName=database_name;"
      #    removeAbandoned="true"
      #    removeAbandonedTimeout="30"
      #    logAbandoned="true" />
      #
      # <Resource
      #    name = "jdbc/<entity>"
      #    auth = 'Container'
      #    type = 'javax.sql.DataSource'
      #    driverClassName = 'oracle.jdbc.OracleDriver'
      #    url = "jdbc:oracle:thin:@//<hostname>:<port>/<sid>"
      #    username = "<username>"
      #    password = "<password>"
      #    connectionProperties = 'SetBigStringTryClob = true'
      #    accessToUnderlyingConnectionAllowed = 'true'
      #    maxTotal = '60'
      #    maxIdle = '20'
      #    maxWaitMillis = '10000'
      # />

      table_name = 'dbo.items'
      entity = 'Entity Name'
      class_name = 'TestConnectionWithXMLXpathReader'
      config_file_path = "#{catalina_home}/conf/context.xml"
      sourcfile = "#{class_name}.java"
      source = <<-EOF
        import java.io.File;
        import java.io.FileInputStream;
        import java.io.IOException;

        import javax.xml.parsers.DocumentBuilder;
        import javax.xml.parsers.DocumentBuilderFactory;
        import javax.xml.parsers.ParserConfigurationException;
        import javax.xml.xpath.XPath;
        import javax.xml.xpath.XPathConstants;
        import javax.xml.xpath.XPathExpressionException;
        import javax.xml.xpath.XPathFactory;

        import org.w3c.dom.Document;
        import org.w3c.dom.Element;
        import org.xml.sax.SAXException;

        import java.sql.Connection;
        import java.sql.DriverManager;
        import java.sql.ResultSet;
        import java.sql.Statement;
        import java.sql.SQLException;

        public class Test #{class_name} {
          public static void main(String[] args)
              throws SAXException, IOException, ParserConfigurationException,
              XPathExpressionException, ClassNotFoundException, SQLException {
            String tableName = "#{table_name}";
            DocumentBuilder db = (DocumentBuilderFactory.newInstance())
                .newDocumentBuilder();
            String configFilePath = "#{config_file_path}";
            Document document = db.parse(new FileInputStream(new File(configFilePath)));
            XPath xpath = (XPathFactory.newInstance()).newXPath();
            String entity = "#{entity}";
            // NOTE: quotes
            String xpathLocator = String
                .format("/Context/Resource[ @name = \\"jdbc/%s\\"]", entity);
            System.err.println(String.format("Looking for \\"%s\\"", xpathLocator));
            Element userElement = (Element) xpath.evaluate(xpathLocator, document,
                XPathConstants.NODE);
            String username = userElement.getAttribute("username");
            String password = userElement.getAttribute("password");
            String driverClassName = userElement.getAttribute("driverClassName");
            Class.forName(driverClassName);

            String url = userElement.getAttribute("url");
            System.err.println(
                String.format("connecting to %s as \\"%s\\"/\\"%s\\"", url, username, password));
            Connection m_Connection = DriverManager.getConnection(url, username,
                password);

            Statement m_Statement = m_Connection.createStatement();
            String query = String.format("SELECT * FROM %s", tableName);

            ResultSet m_ResultSet = m_Statement.executeQuery(query);

            while (m_ResultSet.next()) {
              System.out.println(m_ResultSet.getString(1) + ", "
                  + m_ResultSet.getString(2) + ", " + m_ResultSet.getString(3));
            }
          }
        }
    EOF
    describe command(<<-EOF
      pushd /tmp
      echo '#{source}' > '#{sourcfile}'
      javac '#{sourcfile}'
      java -cp #{jars_cp}:. '#{class_name}'
      popd
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('\d+, \d+, \d+$', Regexp::IGNORECASE) }
    end
  end
  context 'Passing connection parameters directly' do
  # origin: http://docs.oracle.com/javase/tutorial/jdbc/basics/processingsqlstatements.html
    catalina_home =  '/apps/tomcat/7.0.77'
    table = ''
    jdbc_prefix = 'sqlserver'
    jdbc_driver_class_name = 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
    database_host = ''
    database_name = ''
    username = ''
    password =  ''
    class_name = 'TestConnectionSimple'
    sourcfile = "#{class_name}.java"
    source = <<-EOF
      import java.sql.CallableStatement;
      import java.sql.Connection;
      import java.sql.DriverManager;
      import java.sql.ResultSet;
      import java.sql.Statement;

      public class #{class_name} {
        public static void main(String[] argv) throws Exception {
          Class.forName("#{jdbc_driver_class_name}");

          Connection connection = DriverManager.getConnection(
              "jdbc:#{jdbc_prefix}://#{database_host};databaseName=#{database_name}",
              "#{username}", "#{password}");

          Statement statement = null;
          String query = "select * from #{table}";
          try {
            statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(query);
            while (resultSet.next()) {
              String id = resultSet.getString("ITEM_REFERENCE_ID");
              System.out.println("ITEM_REFERENCE_ID: " + id);
            }
          } catch (Exception e) {
            e.printStackTrace();
          } finally {
            if (statement != null) {
              statement.close();
            }
          }
        }
      }
    EOF
    describe command(<<-EOF
      pushd $env:TEMP
      pushd /tmp
      echo '#{source}' > '#{sourcfile}'
      javac '#{sourcfile}'
      java -cp #{jars_cp}#{path_separator}. '#{class_name}'
      popd
    EOF
    ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /ITEM_REFERENCE_ID: \d+/}
      end
    end
  end
end
