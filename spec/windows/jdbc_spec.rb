require_relative '../windows_spec_helper'

context 'JDBC tests' do

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
