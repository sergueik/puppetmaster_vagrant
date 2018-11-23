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
while manageable by an largely equivalent `augtool` script:

```shell
set '/augeas/load/xml/lens' 'Xml.lns'
set '/augeas/load/xml/incl' '<%= @tomcat_config_file -%>'
load
# NOTE: assumes the <web-app><session-config><session-timeout>30</session-timeout><session-config></web-app>
# is present
insert 'filter' before '/files/<%= @tomcat_config_file -%>/web-app/session-config/session-timeout[#text="30"][parent::*]'
# Specify position within the node set to protect against
# "too many matches for path expression" augeas error when dublicate nodes are present in the XML

set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/filter-name/#text' 'httpHeaderSecurity'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/filter-class/#text' 'org.apache.catalina.filters.HttpHeaderSecurityFilter'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/async-supported/#text' 'true'
save
print '/files<%= @tomcat_config_file -%>/web-app/filter[last()]'

insert 'filter-mapping' before '/files<%= @tomcat_config_file -%>/web-app/session-config'

set '/files<%= @tomcat_config_file -%>/web-app/filter-mapping[last()]/filter-name/#text' 'httpHeaderSecurity'
set '/files<%= @tomcat_config_file -%>/web-app/filter-mapping[last()]/url-pattern/#text' '/*'
set '/files<%= @tomcat_config_file -%>/web-app/filter-mapping[last()]/dispatcher/#text' 'REQUEST'
save
print '/files<%= @tomcat_config_file -%>/web-app/filter-mapping[last()]'

insert 'init-param' after '/files<%= @tomcat_config_file -%>/web-app/filter/async-supported'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/init-param[1]/param-name/#text' 'antiClickJackingEnabled'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/init-param[1]/param-value/#text' 'true'
insert 'init-param' after '/files<%= @tomcat_config_file -%>/web-app/filter/async-supported'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/init-param[1]/param-name/#text' 'antiClickJackingOption'
set '/files<%= @tomcat_config_file -%>/web-app/filter[last()]/init-param[1]/param-value/#text' 'SAMEORIGIN'
save
print '/files<%= @tomcat_config_file -%>/web-app/filter[last()]'
# finally print errors
print '/augeas//error'
```

### See Also
  * [REXML Tutorial](http://www.germane-software.com/software/rexml/docs/tutorial.html) for `insert_after` example.
  * [example Puppet enc.sh](https://github.com/T-Systems-MMS/puppet-example-enc)
  * [penetration experts memo of apache tomcat 8.2 (link appears dead)](https://www.pentestingexperts.com/how-to-enable-secure-http-header-in-apache-tomcat-8-2)
  * [How to Enable Secure HTTP Header in Apache Tomcat 8](https://geekflare.com/tomcat-http-security-header/)
  * [Augeas XPath-like grammar](https://github.com/hercules-team/augeas/wiki/Path-expressions#Axes)

### License
This project is licensed under the terms of the MIT license.
### Sample Jenkins command
```xml
<![CDATA[
# the shell retry logic follows.
ERROR_PATTERNS_STR='(?end of file reached|failed to generate additional resource|encountered end of file|feiled to list packages|retrieving certificate failed)'
LOG_FILE='/tmp/process.log'
MAX_RETRY=
TRY=$MAX_RETRY
while [[ $TRY != 0 ]] ; do
  &lt;some REST / curl command&gt;
  grep -qiE $ERROR_PATTERNS_STR $LOG_FILE &gt; /dev/null
  if [[ $? -eq 0 ]]
  then
    TRY=$(expr $TRY - 1)
    TRY_COUNT=$(expr $MAX_RETRY - $TRY)
    echo &quotERROR: RETRY $TRY_COUNT&quot
  else
    TRY=0
  fi
done
]]>
</command>
<!-- The shell script is loaded from inline newline-preserving string hiera parameter -->

```
The error detection wrapper script can be easily made more complex. It is deoupled from the actual 'build'  script:
the two are merged vi Pupper
`%{hiera('class_name::parameter_name')}` [lookup function](https://puppet.com/docs/hiera/3.3/variables.html).

The array of patterns used for the log scan (both test positive and test negative are possible) is constructed through Puppet 'code':

```puppet
  $error_patterns_str = regsubst(regsubst($error_patterns.join('|'),'^' ,'(?' ,'' ),'$' ,')' ,'')
```
The above converts an array `['a','b','c']` into a non-capturing Regex inline constructor argument `(?:|b|c)`.

The HTML encodeded data is also produced by Puppet, the hiera parameter `urugeas::shell_command` is a *raw* bash code:
```puppet
  String $shell_command = lookup('urugeas::shell_command'),
  $cdata = regsubst(regsubst(regsubst(regsubst(regsubst($shell_command, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;', 'G'), "'", '&apos;', 'G')
```

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
