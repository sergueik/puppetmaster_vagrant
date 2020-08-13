# -*- mode: puppet -*-
# vi: set ft=puppet :

class urugeas::python_inline (
  Optional[Hash] $attributes = {},
  Optional[String] $tools_path = '/tmp',
){
    # run in environment where use of Ruby gems is discouraged
    $catalina_home = '/opt/tomcat'
    $tomcat_conf = "${catlina_home}/conf"
    $xml_file = 'server.xml'
    exec { "Fix ${tomcat_conf}/${xml_file}":
      command   => "python -c 'import sys; from xml.dom import minidom; x=minidom.parse(sys.argv[1]); n = x.getElementsByTagName(\"Server\")[0];n.setAttribute(\"port\",\"-1\");n.setAttribute(\"shutdown\",\"MWSSTOP\");x.writexml(open(sys.argv[2], \"w+\"));' ${tomcat_conf}/${xml_file} /tmp/${xml_file};mv /tmp/${xml_file} ${tomcat_conf}",
      path      => '/bin:/usr/bin',
      require   => [File[$tomcat_config_file],File[$augtool_script]],
      unless    => "xmllint --xpath '//Server[@shutdown != \"MWSSTOP\"]/@shutdown' ${tomcat_conf}/${xml_file}",
      returns   => [0,1],
      logoutput => true,
    }
}
