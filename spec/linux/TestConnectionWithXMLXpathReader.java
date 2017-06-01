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

// based on: 
// https://stackoverflow.com/questions/25259836/how-to-get-attribute-value-using-xpath-in-java
// http://www.java2s.com/Code/Java/Development-Class/CommandLineParser.htm
// http://www.java2s.com/Code/Java/Database-SQL-JDBC/Connecttoadatabaseandreadfromtable.htm
// need to run with 
// `java -cp sqljdbc4-2.0.jar;. TestConnectionWithXMLXpathReader`
// the jdbc driver is likely to be provisioned to the instance

public class TestConnectionWithXMLXpathReader {
	public static void main(String[] args)
			throws SAXException, IOException, ParserConfigurationException,
			XPathExpressionException, ClassNotFoundException, SQLException {
		String databaseServer = "localhost";
		String databasePort = "1433";
		String databaseName = "database";
		String tableName = "dbo.items"; // "table";
		DocumentBuilder db = (DocumentBuilderFactory.newInstance())
				.newDocumentBuilder();
		String configFilePath = "context.xml";
		Document document = db.parse(new FileInputStream(new File(configFilePath)));
		XPath xpath = (XPathFactory.newInstance()).newXPath();
    String entity = "Tridion_Broker";
		String xpathLocator = String.format("/Context/Resource[ @name = 'jdbc/%s']", entity);
		Element userElement = (Element) xpath.evaluate(xpathLocator, document,
				XPathConstants.NODE);
		String userId = userElement.getAttribute("username");
		String password = userElement.getAttribute("password");
		// NOTE the following code is MS SQL jdbc version - dependent:
		// for sqljdbc4
		// Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver");
		// for sqljdbc4.2
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    String url = 	userElement.getAttribute("url");
    System.err.println(String.format("connecting to %s as %s/%s", url, userId, password));
		Connection m_Connection = DriverManager.getConnection( (url != null ) ?  url: 
      String.format("jdbc:microsoft:sqlserver://%s:%s;DatabaseName=%s",	databaseServer, databasePort, databaseName),
				userId, password);

		Statement m_Statement = m_Connection.createStatement();
		String query = String.format("SELECT * FROM %s", tableName);

		ResultSet m_ResultSet = m_Statement.executeQuery(query);

		while (m_ResultSet.next()) {
			System.out.println(m_ResultSet.getString(1) + ", "
					+ m_ResultSet.getString(2) + ", " + m_ResultSet.getString(3));
		}
	}
}
