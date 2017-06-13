require 'spec_helper'
#
#if File.exists?( 'spec/windows_spec_helper.rb')
#  require_relative '../windows_spec_helper'
# end
context 'JDBC test request' do

  # origin: http://docs.oracle.com/javase/tutorial/jdbc/basics/processingsqlstatements.html

  catalina_home =  '/apps/tomcat/7.0.77'
  table = ''
  jdbc_prefix = 'sqlserver'
  jdbc_driver_class_name = 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
  database_host = ''
  database_name = ''
  class_name = 'TestConnectionSimple'
  username = ''
  password =  ''

  sourcfile = "#{class_name}.java"

  source = <<-EOF

    import java.sql.CallableStatement;
    import java.sql.Connection;
    import java.sql.DriverManager;
    import java.sql.ResultSet;
    import java.sql.Statement;

    public class TestConnectionSimple {
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
