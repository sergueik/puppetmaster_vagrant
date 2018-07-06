### Info

This directory contains a replica of the Puppet 5.x skeleton role/profile/hieradata Vagrantfile project [example_puppet-serverspec](https://github.com/wstinkens/example_puppet-serverspec/) set up to practice [augeas-driven](https://twiki.cern.ch/twiki/bin/view/Main/TerjeAndersenAugeas) XML file modifications.

This class adds the fllowing two DOM nodes to `/usr/share/tomcat/conf/web.xml`:

```xml
<filter>
  <filter-name>httpHeaderSecurity</filter-name>
  <filter-class>org.apache.catalina.filters.HttpHeaderSecurityFilter</filter-class>
  <async-supported>true</async-supported>
  <init-param>
    <param-name>antiClickJackingEnabled</param-name>
    <param-value>true</param-value>
  </init-param>
  <init-param>
    <param-name>antiClickJackingOption</param-name>
    <param-value>SAMEORIGIN</param-value>
  </init-param>
</filter>
```
and
```xml
<filter-mapping>
  <filter-name>httpHeaderSecurity</filter-name>
  <url-pattern>/*</url-pattern>
  <dispatcher>REQUEST</dispatcher>
</filter-mapping>
```
It appears easier for augtool to add then uncomment the present but commented nod.

It looks that tomcat configuration `web.xml` is causing trouble to Puppet `augeas` resource 

shown below will mysteriously fail without any explanation even in debug run.

```puppet
  Array $augeas_security_part1_changes = [
    "insert 'dummy' session-config",
    "set 'dummy/#text' 'some text'"
  ]
  Array $augeas_security_part2_changes = [
    'insert "filter-mapping" before session-config',
    'set filter-mapping/filter-name/#text "httpHeaderSecurity"',
    'set filter-mapping/url-pattern/#text "/*"',
    'set filter-mapping/dispatcher/#text "REQUEST"',
  ]
  Array $augeas_security_part3_changes = [
    'insert "filter" before session-config',
    'set filter/filter-name/#text "httpHeaderSecurity"',
    'set filter/filter-class/#text "org.apache.catalina.filters.HttpHeaderSecurityFilter"',
    'set filter/async-supported/#text "true"',
    'insert "init-param" after filter/async-supported',
    'set filter/init-param/param-name/#text "antiClickJackingEnabled"',
    'set filter/init-param/param-value/#text "true"',
    'insert "init-param" after filter/async-supported',
    'set filter/init-param[1]/param-name/#text "antiClickJackingOption"',
    'set filter/init-param[1]/param-value/#text "SAMEORIGIN"',
  ]
 augeas{ 'augeas web.xml security changes part 1':
   incl    => '/usr/share/tomcat/conf/web.xml',
   lens    => 'Xml.lns',
   context => '/files/usr/share/tomcat/conf/web.xml',
   changes => $augeas_security_part1_changes,
   require => File['/usr/share/tomcat/conf/web.xml'],
 }
 -> augeas{ 'augeas web.xml security changes part 2':
   incl    => '/usr/share/tomcat/conf/web.xml',
   lens    => 'Xml.lns',
   context => '/files/usr/share/tomcat/conf/web.xml',
   changes => $augeas_security_part2_changes,
 }
 -> augeas{ 'augeas web.xml security changes part 3':
   incl    => '/usr/share/tomcat/conf/web.xml',
   lens    => 'Xml.lns',
   context => '/files/usr/share/tomcat/conf/web.xml',
   changes => $augeas_security_part3_changes,
 }
```
while manageable by an equivalent `augtool` script. 
```shell
set /augeas/load/xml/lens 'Xml.lns'
set /augeas/load/xml/incl  '/var/lib/jenkins/web.xml'
load

# insert 'dummy' before /files/var/lib/jenkins/web.xml/web-app/session-config
# set '/files/var/lib/jenkins/web.xml/web-app/dummy/#text' 'some puppt generated text'
# save
# print /files//var/lib/jenkins/web.xml/web-app/dummy

# part 1 
insert "filter-mapping" before /files/var/lib/jenkins/web.xml/web-app/session-config
save
set /files/var/lib/jenkins/web.xml/web-app/filter-mapping/filter-name/#text "httpHeaderSecurity"
set /files/var/lib/jenkins/web.xml/web-app/filter-mapping/url-pattern/#text "/*"
set /files/var/lib/jenkins/web.xml/web-app/filter-mapping/dispatcher/#text "REQUEST"

save
print /files/var/lib/jenkins/web.xml/web-app/filter-mapping

# part 2
insert "filter" before /files/var/lib/jenkins/web.xml/web-app/session-config
set /files/var/lib/jenkins/web.xml/web-app/filter/filter-name/#text "httpHeaderSecurity"
set /files/var/lib/jenkins/web.xml/web-app/filter/filter-class/#text "org.apache.catalina.filters.HttpHeaderSecurityFilter"
set /files/var/lib/jenkins/web.xml/web-app/filter/async-supported/#text "true"
save
print /files/var/lib/jenkins/web.xml/web-app/filter

# part 3
insert "init-param" after /files/var/lib/jenkins/web.xml/web-app/filter/async-supported
set /files/var/lib/jenkins/web.xml/web-app/filter/init-param/param-name/#text "antiClickJackingEnabled"
set /files/var/lib/jenkins/web.xml/web-app/filter/init-param/param-value/#text "true"
insert "init-param" after /files/var/lib/jenkins/web.xml/web-app/filter/async-supported
set /files/var/lib/jenkins/web.xml/web-app/filter/init-param[1]/param-name/#text "antiClickJackingOption"
set /files/var/lib/jenkins/web.xml/web-app/filter/init-param[1]/param-value/#text "SAMEORIGIN"

save
print /files/var/lib/jenkins/web.xml/web-app/filter-mapping
```
### See Also
  * [REXML Tutorial](http://www.germane-software.com/software/rexml/docs/tutorial.html) for `insert_after` example.
  * [example Puppet enc.sh](https://github.com/T-Systems-MMS/puppet-example-enc)

### License
This project is licensed under the terms of the MIT license.

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
