# -*- mode: puppet -*-
# vi: set ft=puppet :

# The Puppet "defined type" is used internally by he Puppet "class"
# to handle multiple declarations per node scope and class parameter lookup

define urugeas::hieradata_check::worker (
  Variant[String,Undef] $long = lookup('urugeas::hieradata_check::long', {'default_value' => '42-dev'}),
  Variant[String,Integer] $short = lookup('urugeas::hieradata_check::short', {'default_value' => 42}),
  String $search = hiera('urugeas::hieradata_check::search'),
  String $replace = hiera('urugeas::hieradata_check::replace'),
  Boolean $debug  = false,
) {
  if $debug {
    notify {"${name} called": }
  }
  $probe = regsubst($long, $search, $replace)
  # Error: This 'if' statement has no effect. A value was produced and then forgotten
  if "${probe}" == '' {
    if $debug {
      notify {"Failing to extract the value from \"${long}\"":
        message => "using search = \"${search}\", replace = \"${replace}\"",
      }
    }
  }
  if $probe == $short {
    if $debug {
      notify {"Mismatch extracted vs. expected in\"${long}\"":
        message => "extracted= \"${probe}\", exected = \"${short}\"",
      }
    }

  } else {
    if $debug {
      notify {"All good match \"${long}\" yields \"${short}\"": }
    }

  }
}
