# -*- mode: puppet -*-
# vi: set ft=puppet :

class urugeas::jetty_mod (
  Optional[Hash] $headers = {},
  Optional[String] $tools_path                  = '/tmp',
) {
  # validate_hash($headers)
  
  $jetty_xml_template = 'jetty_xml'
  $jetty_xml = 'jetty.xml'
  file { $jetty_xml:
    ensure  => file,
    path    => "${tools_path}/jetty.xml",
    content => template("${module_name}/${jetty_xml_template}.erb"),
    mode    => '0755',
  }
}
