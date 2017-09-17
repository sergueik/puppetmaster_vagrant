require_relative '../windows_spec_helper'

context 'JDBC tests' do
  # http://www.sqlines.com/articles/java/sql_server_jdbc_connection
  context 'MS SQL', :if => os[:family] == 'windows' do
    jdbc_prefix = 'sqlserver'
    jdbc_driver_class_name = 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
    jdbc_path = "c:\\users\\sergueik\\desktop"
    database_host = 'localhost'
    database_name = 'testdb'
    path_separator = ';'
    # https://www.microsoft.com/en-us/download/details.aspx?id=11774
    # TODO: automate
    # pushd "$env:{USERPROFILE}\Downloads"
    # copy 
    # Microsoft JDBC Driver 6.0 for SQL Server\\sqljdbc_6.0\\enu\\auth\\x64\\sqljdbc_auth.dll
    # Microsoft JDBC Driver 6.0 for SQL Server\\sqljdbc_6.0\\enu\\auth\\x86\\sqljdbc_auth.dll
    # to 
    # c:\Windows\system32
    jars = ['sqljdbc41.jar','sqljdbc42.jar', 'sqljdbc_6.0']
    jars_cp = jars.collect{|jar| "#{jdbc_path}\\#{jar}"}.join(';')
    context 'Using Windows authentication' do
      table_name = 'sys.columns'
      class_name = 'TestConnectionWithWindowsAuthentication'
      sourcfile = "#{class_name}.java"

      source = <<-EOF
        import java.sql.Connection;
        import java.sql.DriverManager;
        import java.sql.ResultSet;
        import java.sql.Statement;

        import java.lang.reflect.*;

        public class #{class_name} {
          private static Connection connection = null;
          private static Statement statement = null;
          private static ResultSet resultSet = null;

          public static void main(String[] argv) throws Exception {
            String className = "#{jdbc_driver_class_name}";
            String tableName = "#{table_name}";
            // not working ?
            System.setProperty("java.library.path",
                "C:\\\\Users\\\\sergueik\\\\Downloads\\\\Microsoft JDBC Driver 6.0 for SQL Server\\\\sqljdbc_6.0\\\\enu\\\\auth\\\\x86\\\\");
            final Field sysPathsField = ClassLoader.class.getDeclaredField("sys_paths");
            sysPathsField.setAccessible(true);
            sysPathsField.set(null, null);
            try {
              Class driverObject = Class.forName(className);
              System.out.println("driverObject=" + driverObject);

              String serverName = "#{database_host}";
              String databaseName = "#{database_name}";
              String url = "jdbc:#{jdbc_prefix}://" + serverName + ":1434;databaseName="
                  + databaseName + ";integratedSecurity=true;";
              url = "jdbc:sqlserver://localhost:1434;domain=SERGUEIK42;databaseName=testdb;integratedSecurity=true;";
              try {
                connection = DriverManager.getConnection(url);
                statement = connection.createStatement();
                String query = String.format("SELECT * FROM %s", tableName);

                resultSet = statement.executeQuery(query);

                while (resultSet.next()) {
                  System.out.println(resultSet.getString(1) + ", "
                      + resultSet.getString(2) + ", " + resultSet.getString(3));
                }
              } catch (Exception e1) {
                System.out.println("Exception: " + e1.getMessage());
              } finally {
                if (connection != null)
                  try {
                    connection.close();
                  } catch (Exception e3) {
                  }
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
        $env:PATH = "${env:PATH};c:\\java\\jdk1.8.0_101\\bin"
        javac '#{class_name}.java'
        cmd %%- /c "java  -Djava.library.path=C:\\windows\\system32 -cp #{jars_cp}#{path_separator}. #{class_name}"
      EOF
      ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match Regexp.new('\d+, (name|filename|status|column_guid|queuing_order|minoccur), \d+$', Regexp::IGNORECASE) }
      end
      # Exception: This driver is not configured for integrated authentication. ClientConnectionId:...
      # com.microsoft.sqlserver.jdbc.AuthenticationJNI <clinit>
      # WARNING: Failed to load the sqljdbc_auth.dll cause : no sqljdbc_auth in java.library.pat
    end  
  end
  context 'MySQL', :if => os[:family] == 'windows' do
    context 'Passing connection parameters directly' do
      # origin: http://www.java2s.com/Code/Java/Database-SQL-JDBC/TestMySQLJDBCDriverInstallation.htm
      table = ''
      jdbc_prefix = 'mysql'
      jdbc_host = 'localhost'
      jdbc_driver_class_name = 'org.gjt.mm.mysql.Driver'
      # location can be arbitrary 
      jdbc_path = 'C:/java/apache-tomcat-7.0.81/webapps/basic-app-1.0-SNAPSHOT/WEB-INF/lib'
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
end
