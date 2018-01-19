


if ENV.has_key?('URU_INVOKER')
  require 'spec_helper'
else
  # NOTE: the directory layout under uru is different
  if File.exists?( 'spec/windows_spec_helper.rb')
    require_relative '../windows_spec_helper'
  else
    require 'spec_helper'
  end
end
# origin: https://www.alibabacloud.com/help/doc-detail/44630.htm
# see also: https://docs.mongodb.com/manual/reference/connection-string/
context 'MongoDB test' do
  catalina_home = '/apps/tomcat/current'
  path_separator = ':'
  application = 'ROOT'
  java_lib_path = "#{catalina_home}/webapps/#{application}/WEB-INF/lib/"

  # MongoDB Java Driver 3.6.1 is an uber-artifact, containing mongodb-driver, mongodb-driver-core, and bson
  mongo_java_driver_jars = ['mongo-java-driver-3.6.1.jar']
  # alterative is the
  mongo_java_driver_jars = ['mongodb-driver-3.4.3.jar','mongodb-driver-core-3.4.3.jar','bson-3.4.3.jar']
  jars_cp = mongo_java_driver_jars.collect{|jar| "#{java_lib_path}/#{jar}"}.join(path_separator)
  class_name = 'TestConnectionWithReplicaSetAndCredentials'
  sourcfile = "#{class_name}.java"
  replicaset = 'rs0'
  database = 'portal'
  authdatabase = 'admin'
  collection = 'dummy'
  username = 'dbuser'
  password = 'wood123'
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
public static ServerAddress serverAddress2 = new ServerAddress( "#{dbhost1}", #{port});      public static ServerAddress serverAddress3 = new ServerAddress( "#{dbhost3}", #{port});      public static String username = "#{username}";      public static String password = "#{password}";      public static String replicaSetName = "#{replicaset}";      public static String databaseName = "#{database}";      public static String authDatabaseName = "#{authdatabase}";      public static String collectionName = "#{collection}";
      
public static void main(String args[]) {
MongoClient client  = null;
try {
MongoClientURI connectionString = new MongoClientURI(
"mongodb://" + username + ":" + password + "@" + serverAddress1 + "," + serverAddress2 + "," + serverAddress3
+ "/" + databaseName + "?replicaSet=" + replicaSetName + "&" + "authSource=" + authDatabaseName );
client = new MongoClient(connectionString);
// Get the Collection handle.
MongoDatabase database = client.getDatabase(databaseName);
MongoCollection collection = database.getCollection(collectionName);
} finally {
// Close the client and release resources.
if (client != null){
client.close();
}
}
return;
}
      public static void main_BROKEN(String args[]) {
MongoClientURI connectionString = new MongoClientURI(
"mongodb://" + username + ":" + password + "@" + serverAddress1 + "," + serverAddress2 + "," + serverAddress3
+ "/" + databaseName + "?replicaSet=" + replicaSetName + "&" + "authSource=" + authDatabaseName );
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
databaseName, password.toCharArray()));
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
javac -cp #{jars_cp}#{path_separator}. '#{sourcfile}'
java -cp #{jars_cp}#{path_separator}. '#{class_name}'
popd  
EOF
  ) do    
    its(:exit_status) { should eq 0 }
    # its(:stdout) { should contain 'MongoDB test' }
    its(:stderr) { should contain 'Cluster' }
  end
  # NOTE: if there was no replica set in the first place  
  # this test would get a somewhat misleading `success` status:   
  # INFO: Cluster created with settings {hosts=[mongodb://dbuser:wood123@json-store-0.puppet.localdomain:27017,json-store-0.puppet.localdomain:27017,json-store-2.puppet.localdomain:27017/portal?replicaset=rs0&authsource=admin:27017], mode=SINGLE, requiredClusterType=UNKNOWN, serverSelectionTimeout='30000 ms', maxWaitQueueSize=500}  
  # INFO: Adding discovered server json-store-0.puppet.localdomain:27017 to client view of cluster
end
