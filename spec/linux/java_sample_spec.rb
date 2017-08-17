# NOTE: this logic not correct under uru 
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end

context 'JDBC tests' do
  context 'Oracle' do
    # based on:
    # http://www.java2s.com/Tutorial/Java/0340__Database/ConnectwithOraclesJDBCThinDriver.htm
    # https://confluence.atlassian.com/doc/configuring-an-oracle-datasource-in-apache-tomcat-339739363.html
    context 'Passing connection parameters directly' do
      # <Resource
      #   name="jdbc/confluence"
      #   auth="Container"
      #   type="javax.sql.DataSource"
      #   driverClassName="oracle.jdbc.OracleDriver"
      #   url="jdbc:oracle:thin:@hostname:port:sid"
      #   username="<username>"
      #   password="<password>"
      #   connectionProperties="SetBigStringTryClob=true"
      #   accessToUnderlyingConnectionAllowed="true"
      #   maxTotal="60"
      #   maxIdle="20"
      #   maxWaitMillis="10000"
      # />

      jdbc_prefix = 'oracle:thin'
      jdbc_host = 'localhost'
      port_number = 3203
      jdbc_driver_class_name = 'oracle.jdbc.driver.OracleDriver'
      jdbc_path = '/var/run'
      jars = ['ojdbc7.jar']
      path_separator = ':'
      jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(path_separator)
      database_host = 'localhost'
      database_query = 'SELECT DUMMY FROM dual'
      sid_name = 'sid'
      username = 'root'
      password = 'password'
      class_name = 'Test'
      sourcfile = "#{class_name}.java"

      source = <<-EOF
        import java.sql.Connection;
        import java.sql.DriverManager;
        import java.sql.ResultSet;
        import java.sql.Statement;

        public class #{class_name} {
          public static void main(String[] args) throws Exception {
            Connection conn = getConnection();
            Statement st = conn.createStatement();
            String query = "#{database_query}";
            ResultSet rs = st.executeQuery(query);
                  while (rs.next()) {
                    System.out.println(rs.getString(1));
                  }

            rs.close();
            st.close();
            conn.close();
          }
          private static Connection getConnection() throws Exception {
            String driver = "#{jdbc_driver_class_name}";
            // try/catch
            try {
              Class.forName(driver);
            } catch (Exception e) {
              System.out.println("Exception: " + e.getMessage());
            }
            String serverName = "#{database_host}";
            int portNumber = #{port_number};
            String sidName = "#{sid_name}";
            String url = "jdbc:#{jdbc_prefix}:@//" + serverName + ":" + portNumber +  "/" + sidName;
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

  context 'MySQL', :if => os[:family] == 'windows' do
    # The following fragment is tailored to run in Windows node
    context 'Passing connection parameters directly' do
      # origin: http://www.java2s.com/Code/Java/Database-SQL-JDBC/TestMySQLJDBCDriverInstallation.htm
      table = ''
      jdbc_prefix = 'mysql'
      jdbc_host = 'localhost'
      jdbc_driver_class_name = 'org.gjt.mm.mysql.Driver'
      jdbc_path = '.'
      jars = ['com.mysql.jdbc_5.1.5.jar']
      path_separator = ';'
      jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(path_separator)
      database_host = 'localhost'
      database_name = 'information_schema'
      username = 'root'
      password = 'password'

      class_name = 'Test'

      source = <<-EOF
        import java.sql.Connection;
        import java.sql.DriverManager;

        public class #{class_name} {
          public static void main(String[] argv) throws Exception {
           String className = "#{jdbc_driver_class_name}";
           try {
              Class driverObject = Class.forName(className);
              System.out.println("driverObject=" + driverObject);

              String serverName = "#{database_host}";
              String databaseName = "#{database_name}";
              String url = "jdbc:#{jdbc_prefix}://" + serverName + "/" + databaseName;

              String username = "#{username}";
              String password = "#{password}";
              try {
                Connection connection = DriverManager.getConnection(url, username, password);
              } catch (Exception e1) {
                System.out.println("Exception: " + e1.getMessage());
              }
            } catch (Exception e2) {
              System.out.println("Exception: " + e2.getMessage());
            }
          }
        }
      EOF
      describe command(<<-EOF
        pushd $env:USERPROFILE
        write-output '#{source}' | out-file #{class_name}.java -encoding ASCII
        $env:PATH = "${env:PATH};c:\\java\\jdk1.7.0_65\\bin"
        javac '#{class_name}.java'
        cmd %%- /c "java -cp #{jars_cp}#{path_separator}. #{class_name}"
      EOF
      ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /driverObject=class #{jdbc_driver_class_name}/}
      end
    end
  end

  context 'MS SQL' do
    catalina_home = '/apps/tomcat/7.0.77'
    jdbc_prefix = 'microsoft:sqlserver'
    jdbc_path = "#{catalina_home}/webapps/cd_upload/WEB-INF/lib"
    jars = ['sqljdbc41.jar','sqljdbc42.jar', 'sqljdbc_6.0']
    jars_cp = jars.collect{|jar| "#{jdbc_path}/#{jar}"}.join(':')
    context 'Using tomcat context.xml' do
      # based on:
      # https://stackoverflow.com/questions/25259836/how-to-get-attribute-value-using-xpath-in-java
      # http://www.java2s.com/Code/Java/Development-Class/CommandLineParser.htm
      # http://www.java2s.com/Code/Java/Database-SQL-JDBC/Connecttoadatabaseandreadfromtable.htm

      #		<Resource name="jdbc/database_name"
      #		    auth="Container"
      #		    factory="org.apache.tomcat.dbcp.dbcp.BasicDataSourceFactory"
      #		    driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
      #		    type="javax.sql.DataSource"
      #		    maxActive="50"
      #		    maxIdle="10"
      #		    maxWait="15000"
      #		    username="..."
      #		    password="..."
      #		    url="jdbc:sqlserver://database_host;databaseName=database_name;"
      #		    removeAbandoned="true"
      #		    removeAbandonedTimeout="30"
      #		    logAbandoned="true" />
      #
      table_name = 'dbo.items'
      entity = 'Tridion_Broker'
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
            // NOTE: quotes
            String xpathLocator = String.format("/Context/Resource[ @name = \"jdbc/%s\"]", entity);
            System.err.println(String.format("Looking for \"%s\"" , xpathLocator)) ;
            Element userElement = (Element) xpath.evaluate(xpathLocator, document,
                XPathConstants.NODE);
            String userId = userElement.getAttribute("username");
            String password = userElement.getAttribute("password");
            String driverClassName = userElement.getAttribute("driverClassName");
            Class.forName(driverClassName);

            String url = 	userElement.getAttribute("url");
            System.err.println(String.format("connecting to %s as %s/%s", url, userId, password));
            Connection m_Connection = DriverManager.getConnection(url,userId, password);

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

            Connection con = DriverManager.getConnection("jdbc:#{jdbc_prefix}://#{database_host};databaseName=#{database_name}",
                "#{username}", "#{password}");

            Statement stmt = null;
            String query = "select * from #{table}";
            try {
                stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    String item_reference_Id = rs.getString("ITEM_REFERENCE_ID");
                    System.out.println("ITEM_REFERENCE_ID: " + item_reference_Id);
                }
            } catch (Exception e ) {
                e.printStackTrace();
            } finally {
                if (stmt != null) { stmt.close(); }
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
