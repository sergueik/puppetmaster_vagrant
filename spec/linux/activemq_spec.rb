require 'spec_helper'

# origin: http://activemq.apache.org/hello-world.html
# see also: https://github.com/fanlychie/activemq-samples/blob/master/activemq-quickstart/src/main/java/org/fanlychie/mq/Consumer.java

context 'ActiveMQ Hello World Test' do


  activemq_home = '/opt/bitnami/activemq'
  path_separator = ':'
  application = 'Tomcat Application Name'
  jar_path = "#{activemq_home}/lib/"
  message = 'Hello world!'
  # NOTE: compile and package with maven to figure out the dependencies
  pom = <<-EOF
<?xml version="1.0"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>org.fanlychie</groupId>
      <artifactId>activemq-quickstart</artifactId>
      <version>1.0-SNAPSHOT</version>
      <packaging>jar</packaging>
      <name>activemq-quickstart</name>
      <url>http://maven.apache.org</url>
      <properties>
        <activemq.version>5.15.2</activemq.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      </properties>
      <dependencies>
        <dependency>
          <groupId>org.apache.activemq</groupId>
          <artifactId>activemq-broker</artifactId>
          <version>${activemq.version}</version>
        </dependency>
      </dependencies>
      <build>
        <plugins>
          <plugin>
            <artifactId>maven-dependency-plugin</artifactId>
            <executions>
              <execution>
                <phase>install</phase>
                <goals>
                  <goal>copy-dependencies</goal>
                </goals>
                <configuration>
                  <outputDirectory>${project.build.directory}/lib</outputDirectory>
                </configuration>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </project>
  EOF
  jar_path = '/var/tmp/target/lib/'
  jars = [
        'activemq-broker-5.15.2.jar',
        'activemq-client-5.15.2.jar',
        'activemq-kahadb-store-5.15.3.jar',
        'activemq-openwire-legacy-5.15.2.jar',
        'activemq-protobuf-1.1.jar',
        'geronimo-j2ee-management_1.1_spec-1.0.1.jar',
        'geronimo-jms_1.1_spec-1.1.1.jar',
        'guava-18.0.jar',
        'hawtbuf-1.11.jar',
        'jackson-annotations-2.6.0.jar',
        'jackson-core-2.6.7.jar',
        'jackson-databind-2.6.7.jar',
        'slf4j-api-1.7.25.jar',
  ]
  jars_cp = jars.collect{|jar| "#{jar_path}/#{jar}"}.join(path_separator)
  server_ipaddress = '127.0.0.1'
  server_port = 61616
  class_name = 'ActiveMQConsumer'
  sourcfile = "#{class_name}.java"
  source = <<-EOF

    import org.apache.activemq.ActiveMQConnectionFactory;

    import javax.jms.Connection;
    import javax.jms.DeliveryMode;
    import javax.jms.Destination;
    import javax.jms.ExceptionListener;
    import javax.jms.JMSException;
    import javax.jms.Message;
    import javax.jms.MessageConsumer;
    import javax.jms.MessageProducer;
    import javax.jms.Session;
    import javax.jms.TextMessage;

    public class #{class_name} {

      public static void main(String[] args) throws Exception {
        thread(new HelloWorldProducer(), false);
        Thread.sleep(1000);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        Thread.sleep(1000);
        thread(new HelloWorldConsumer(), false);
        /*
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldProducer(), false);
        Thread.sleep(1000);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldConsumer(), false);
        thread(new HelloWorldProducer(), false);
        */
      }

      public static void thread(Runnable runnable, boolean daemon) {
        Thread brokerThread = new Thread(runnable);
        brokerThread.setDaemon(daemon);
        brokerThread.start();
      }

      public static class HelloWorldProducer implements Runnable {
        public void run() {
          try {
            // Create a ConnectionFactory
            ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(
                "vm://localhost");

            // Create a Connection
            Connection connection = connectionFactory.createConnection();
            connection.start();

            // Create a Session
            Session session = connection.createSession(false,
                Session.AUTO_ACKNOWLEDGE);

            // Create the destination (Topic or Queue)
            Destination destination = session.createQueue("TEST.FOO");

            // Create a MessageProducer from the Session to the Topic or Queue
            MessageProducer producer = session.createProducer(destination);
            producer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);

            // Create a messages
            String text = "#{message} From: " + Thread.currentThread().getName()
                + " : " + this.hashCode();
            TextMessage message = session.createTextMessage(text);

            // Tell the producer to send the message
            System.out.println("Sent message: " + message.hashCode() + " : "
                + Thread.currentThread().getName());
            producer.send(message);

            // Clean up
            session.close();
            connection.close();
          } catch (Exception e) {
            System.out.println("Caught: " + e);
            e.printStackTrace();
          }
        }
      }

      public static class HelloWorldConsumer
          implements Runnable, ExceptionListener {
        public void run() {
          try {

            // Create a ConnectionFactory
            ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(
                "vm://localhost");

            // Create a Connection
            Connection connection = connectionFactory.createConnection();
            // Start the connection
            // NOTE: javax.jms.JMSSecurityException:
            connection.start();

            connection.setExceptionListener(this);

            // Create a Session
            Session session = connection.createSession(false,
                Session.AUTO_ACKNOWLEDGE);

            // Create the destination (Topic or Queue)
            Destination destination = session.createQueue("TEST.FOO");

            // Create a MessageConsumer from the Session to the Topic or Queue
            MessageConsumer consumer = session.createConsumer(destination);

            // Wait for a message
            Message message = consumer.receive(1000);

            // Print received message
            if (message instanceof TextMessage) {
              TextMessage textMessage = (TextMessage) message;
              String text = textMessage.getText();
              System.out.println("Received: " + text);
            } else {
              System.out.println("Received: " + message);
            }

            consumer.close();
            session.close();
            connection.close();
          } catch (Exception e) {
            System.out.println("Caught: " + e);
            e.printStackTrace();
          }
        }

        public synchronized void onException(JMSException ex) {
          System.out.println("JMS Exception occured.  Shutting down client.");
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
      its(:stdout) { should contain(/Sent message: \d+ : Thread\-\d+/)  }
      its(:stdout) { should contain(/Received: #{message} From: Thread-\d+ : \d+ /)  }
    end
  end