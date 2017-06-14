require 'spec_helper'

context 'JDBC tests' do
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
    catalina_home = '/apps/tomcat/7.0.77'
    jdbc_prefix = 'microsoft:sqlserver'
    jdbc_driver_class_name = 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
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
          // NOTE the following code is MS SQL jdbc version - dependent:
          // for sqljdbc4
          // Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver");
          // for sqljdbc4.2
          Class.forName("#{jdbc_driver_class_name}");

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
      java -cp #{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc41.jar:#{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc_6.0:#{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc42.jar:. '#{class_name}'
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
      pushd /tmp
      echo '#{source}' > '#{sourcfile}'
      javac '#{sourcfile}'
      java -cp #{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc41.jar:#{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc_6.0:#{catalina_home}/webapps/cd_upload/WEB-INF/lib/sqljdbc42.jar:. '#{class_name}'
      popd
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /ITEM_REFERENCE_ID: \d+/}
    end
  end
end
