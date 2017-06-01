// origin: http://docs.oracle.com/javase/tutorial/jdbc/basics/processingsqlstatements.html
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestConnectionSimple {
  public static void main(String[] argv) throws Exception {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    Connection con = DriverManager.getConnection("jdbc:sqlserver://<%= @database_host -%>;databaseName=<%= @database -%>",
        "<%= @username -%>", "<%= @password -%>");

    Statement stmt = null;
    String query = "select * from dbo.items";
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

