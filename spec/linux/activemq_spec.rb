require 'spec_helper'

# origin : https://github.com/fanlychie/activemq-samples/blob/master/activemq-quickstart/src/main/java/org/fanlychie/mq/Consumer.java

context 'ActiveMQ tests' do

  activemq_home = '/opt/bitnami/activemq'
  path_separator = ':'
  application = 'Tomcat Application Name'
  jar_path = "#{activemq_home}/lib/"
  driver_class_name = 'oracle.jdbc.driver.OracleDriver'
  version = '5-15.3'
  jars = ["activemq-all-#{version}.jar"]
  jars_cp = jars.collect{|jar| "#{jar_path}/#{jar}"}.join(path_separator)
  server_ipaddress = '127.0.0.1'
  server_port = 61616
  class_name = 'ActiveMQConsumer'
  sourcfile = "#{class_name}.java"
  source = <<-EOF

    import org.apache.activemq.ActiveMQConnectionFactory;

    import javax.jms.Connection;
    import javax.jms.ConnectionFactory;
    import javax.jms.Destination;
    import javax.jms.MessageConsumer;
    import javax.jms.Session;
    import javax.jms.TextMessage;

    public class ActiveMQConsumer {

      public static void main(String[] args) throws Throwable {
        // connect factory
        ConnectionFactory factory = new ActiveMQConnectionFactory("tcp://#{server_ipaddress}:#{server_port}");
        // Create a connection
        Connection conn = factory.createConnection();
        // Start the connection
        conn.start();
        // Create a session
        Session session = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);

        // send destination
        Destination destination = session.createQueue("TEST.QUEUE");

        // Message consumers
        MessageConsumer consumer = session.createConsumer(destination);
        while (true) {
          // Receive messages
          TextMessage message = (TextMessage) consumer.receive();
           // Print received message
          System.out.println(String.format("Received: %s", message.getText()));
        }
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
      its(:stdout) { should contain 'Received: ' }
    end
  end