require 'spec_helper'

context 'Relative XPath' do
    xmlfile = '/tmp/context.xml'

# sibling node locator
  before(:each) do
    # example from http://www.java2s.com/Code/Java/Spring/SetupDriverManagerDataSourceasXMLbean.htm
    content = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springframework.org/dtd/spring-beans.dtd">
<beans>
  <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
    <property name="driverClassName">
      <value>sun.jdbc.odbc.JdbcOdbcDriver</value>
    </property>
    <property name="url">
      <value>jdbc:odbc:test</value>
    </property>
    <property name="username">
      <value>root</value>
    </property>
    <property name="password">
      <value>sql</value>
    </property>
  </bean>
  <bean id="datacon" class="Dataconimpl">
    <property name="dataSource">
      <ref local="dataSource"/>
    </property>
  </bean>
</beans>
    EOF
    Specinfra::Runner::run_command(<<-EOF
      echo '#{content}' > '#{xmlfile}'
      sleep 10
    EOF
    )
  end
  # finding the username attribute on the XML configuration describing a specific driverClassName or url
  describe command( <<-EOF
    xmllint -xpath '/beans/bean[property/value/text() = "sun.jdbc.odbc.JdbcOdbcDriver" ]/property[@name="username"]/value/text()' '#{xmlfile}'
  EOF
  ) do

   [
    'root',
   ].each do |line|
      its(:stdout) { should match Regexp.escape line}
   end
  end

end
