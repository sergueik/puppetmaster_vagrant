# -*- mode: puppet -*-
# vi: set ft=puppet :

class urugeas::hieradata_check (
  Variant[String,Undef] $long = lookup('urugeas::hieradata_check::long', {'default_value' => '42-dev'}),
  Variant[String,Integer] $short =  lookup('urugeas::hieradata_check::short', {'default_value' => 42}),
  String $search = hiera('urugeas::hieradata_check::search'),
  String $replace = hiera('urugeas::hieradata_check::replace'),
) {

  # 'search' and 'replace' cannot be blank - fail when data is not provided
  # Error: Function lookup() did not find a value for the name 
  # 'urugeas::search'

  $debug = true
  urugeas::hieradata_check::worker{ "called by class {name}":
    long    => $long,
    short   => $short,
    search  => $search,
    replace => $replace,
    debug   => $debug,
  }
}
