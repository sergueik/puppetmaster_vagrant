# -*- mode: puppet -*-
# vi: set ft=puppet :

class urugeas::jetty_mod (
  Optional[Hash] $headers = {},
  Optional[String] $tools_path = '/tmp',
) {
  # validate_hash($headers)
  # NOTE: the class name ${name} used for hieradata lookup would include prefix
  $xml_template = lookup("${name}::xml_template", String, first, 'jetty_xml.erb')
  # chop away the .erb extension and convert the preceding _<ext> into and .ext
  $xml_filename = $xml_template.regsubst('_([^_.]+)(?:.erb|epp)*', '.\1')
  notify{"template target filename: ${xml_filename}":
    before => File[$xml_filename]
  }
  file { $xml_filename:
    ensure  => file,
    path    => "${tools_path}/${xml_filename}",
    content => template("${module_name}/${xml_template}"),
    mode    => '0755',
  }
}
