# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 
  $platform_specific_params_string = "a.b.c:'1' b:'2' c:'3' d:''"

  $dummy = regsubst(regsubst($platform_specific_params_string, " +", ',', 'G'), "([^,:]+):'([^']*)'", '"\1":"\2"', 'G')
  
  $platform_specific_params = parsejson("{ ${dummy} }")
  notify {'platform_specific_params test':
    message => inline_template('<% @platform_specific_params.each do |key,val| -%> <%= key -%> = <%= val -%><% end -%>')
  }

}
