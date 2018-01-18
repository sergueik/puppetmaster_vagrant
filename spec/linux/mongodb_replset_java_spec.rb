if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
else
  require 'spec_helper'
end
# NOTE: the directory layout under uru is different

# origin: https://www.alibabacloud.com/help/doc-detail/44630.htm
# see also: https://docs.mongodb.com/manual/reference/connection-string/
context 'MongoDB test' do

  catalina_home = '/opt/tomcat/current'
  path_separator = ':'
  application = 'Tomcat Application Name'
  java_lib_path = "#{catalina_home}/webapps/#{application}/WEB-INF/lib/"
  config_file_path = "#{catalina_home}/conf/context.xml"
  mongo_java_driver_jars = ['mongo-java-driver-3.6.1.jar']
  jars_cp = mongo_java_driver_jars.collect{|jar| "#{java_lib_path}/#{jar}"}.join(path_separator)
  class_name = 'TestConnectionWithReplicaSetAndCredentials'
  sourcfile = "#{class_name}.java"
  replicaset = 'rs0'
  database = 'portal'
  authdatabase = 'admin'
  collection = 'dummy'
  username = 'dbuser'
  passwowd = 'wood123'
  dbhost1 = 'json-store-0.puppet.localdomain'
  dbhost2 = 'json-store-1.puppet.localdomain'
  dbhost3 = 'json-store-2.puppet.localdomain'
  port = 27017

  source = <<-EOF

    import java.util.ArrayList;
    import java.util.List;
    import java.util.UUID;
    import org.bson.BsonDocument;
    import org.bson.BsonString;
    import org.bson.Document;
    import com.mongodb.MongoClient;
    import com.mongodb.MongoClientOptions;
    import com.mongodb.MongoClientURI;
    import com.mongodb.MongoCredential;
    import com.mongodb.ServerAddress;
    import com.mongodb.client.MongoCollection;
    import com.mongodb.client.MongoCursor;
    import com.mongodb.client.MongoDatabase;

    public class #{class_name} {

      public static ServerAddress serverAddress1 = new ServerAddress( "#{dbhost1}", #{port});
      public static ServerAddress serverAddress2 = new ServerAddress( "#{dbhost1}", #{port});
      public static ServerAddress serverAddress3 = new ServerAddress( "#{dbhost3}", #{port});
      public static String username = "#{username}";
      public static String password = "#{password}";
      public static String replicaSetName = "#{replicaset}";
      public static String databaseName = "#{database}";
      public static String authDatabaseName = "#{authdatabase}";
      public static String collectionName = "#{collection}";

      public static void main(String args[]) {
        MongoClientURI connectionString = new MongoClientURI(
            "mongodb://" + username + ":" + password + "@" + serverAddress1 + "," + serverAddress2 + "," + serverAddress3
                + "/" + databaseName + "?replicaSet=" + replicaSetName + "&" + authSource=" + authDatabaseName );
        MongoClient client = new MongoClient(connectionString);
        // or
        // MongoClient client = createMongoDBClient();
        try {
          // Get the Collection handle.
          MongoDatabase database = client.getDatabase(databaseName);
          MongoCollection<Document> collection = database.getCollection(collectionName);
          // Insert data.
          Document doc = new Document();
          String demoname = "rspec:" + UUID.randomUUID();
          doc.append("DEMO", demoname);
          doc.append("MESSAGE", "MongoDB test");
          collection.insertOne(doc);
          System.out.println("inserted document: " + doc);
          // Read data.
          BsonDocument filter = new BsonDocument();
          filter.append("DEMO", new BsonString(demoname));
          MongoCursor<Document> cursor = collection.find(filter).iterator();
          while (cursor.hasNext()) {
            System.out.println("find document: " + cursor.next());
          }
        } finally {
          // Close the client and release resources.
          client.close();
        }
        return;
      }

      // currently unused
      public static MongoClient createMongoDBClient() {

        List<ServerAddress> serverAddressList = new ArrayList<>();
        serverAddressList.add(serverAddress1);
        serverAddressList.add(serverAddress2);
        serverAddressList.add(serverAddress3);

        List<MongoCredential> credentials = new ArrayList<>();
        credentials.add(MongoCredential.createScramSha1Credential(username,
            database, password.toCharArray()));

            MongoClientOptions options = MongoClientOptions.builder()
            .requiredReplicaSetName(replicaSetName).socketTimeout(2000)
            .connectionsPerHost(1).build();
        return new MongoClient(serverAddressList, credentials, options);
      }

    }
  EOF
  describe command(<<-EOF
    pushd /tmp
    echo '#{source}' > '#{sourcfile}'
    javac '#{sourcfile}'
    java -cp #{jars_cp}#{path_separator}. '#{class_name}'
    popd
  EOF
  ) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should contain 'MongoDB test' }
  end
end