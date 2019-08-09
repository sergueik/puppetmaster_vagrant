# -*- mode: puppet -*-
# vi: set ft=puppet :
define urugeas::dummy (
  Variant[String, Undef] $parameter1 = undef,
  Variant[String, Undef] $parameter2 = 'param2_default',
  Variant[String, Array[String]] $parameter3 = ['param03'],
  String $parameter4 = undef,
) {

  notify {"${name} parameter1 = ${parameter1}":}
  notify {"${name} parameter2 = ${parameter2}":}
  notify {"${name} parameter3 = ${parameter3}":}
  notify {"${name} parameter4 = ${parameter4}":}
}

