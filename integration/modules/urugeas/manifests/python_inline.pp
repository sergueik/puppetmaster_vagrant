# -*- mode: puppet -*-
# vi: set ft=puppet :

class urugeas::python_inline (
   Optional[Hash] $data = {
     'a1' => 'b1',
     'a2' => 'b2',
     'a3' => 'b3',
     'a4' => 'b4',
     'a5' => 'b5'
   },
   Optional[String] $tools_path = '/tmp',
){
 $attributes = join([$data.each |String $key, String $value| { "${key},${value}"  }],',')
    # run in environment where use of Ruby gems is discouraged
    $catalina_home = '/opt/tomcat'
    $tomcat_conf = "${catalina_home}/conf"
    $xml_file = 'server.xml'
    # converted with http://jagt.github.io/python-single-line-convert/
    #
    # text = 'a1,b1,a2,b2,a3,b3,a4,b4,a5,b5'
    # data = text.split(',')
    #
    # for k,v in zip(data[0::2], data[1::2]):
    #   print( '{} {}'.format(k,v))
    #
    # exec("""\ndata = 'a1,b1,a2,b2,a3,b3,a4,b4,a5,b5'.split(',')\nfor i,k in zip(data[0::2], data[1::2]):\n  print( '{k} {v}')\n""")
    exec { "Passing argument lists":
      command   => "python -c \"exec(\\\"\\\"\\\"\\ndata = 'a1,b1,a2,b2,a3,b3,a4,b4,a5,b5'.split(',')\nfor k,v in zip(data[0::2], data[1::2]):\\n  print( '{} {}'.format(k,v))\\\"\\\"\\\")\"",
      path      => '/bin:/usr/bin',
      returns   => [0,1],
      logoutput => true,
    }
    exec { "Fix XML ${tomcat_conf}/${xml_file}":
      command   => "python -c 'import sys; from xml.dom import minidom; x=minidom.parse(sys.argv[1]); n = x.getElementsByTagName(\"Server\")[0];n.setAttribute(\"port\",\"-1\");n.setAttribute(\"shutdown\",\"MWSSTOP\");x.writexml(open(sys.argv[2], \"w+\"));' ${tomcat_conf}/${xml_file} /tmp/${xml_file}; mv /tmp/${xml_file} ${tomcat_conf}",
      path      => '/bin:/usr/bin',
      onlyif    => "xmllint --xpath '//Server[@shutdown != \"MWSSTOP\"]/@shutdown' ${tomcat_conf}/${xml_file}",
      returns   => [0,1],
      logoutput => true,
    }
}
