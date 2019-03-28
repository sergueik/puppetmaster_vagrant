# -*- mode: puppet -*-
# vi: set ft=puppet :
class urugeas::defined_check(
  # intentionally not typed to avoid dealing with compiler errors
  # parameter 'dummy_undef' expects a String value, got Undef :  # String
  $dummy_undef = undef,
  $dummy_defined = undef,
  ) {

  # Puppet documentation is possibly incorrectly suggesting single quotes
  # https://puppet.com/docs/puppet/5.4/function.html#defined
  if !defined('$dummy_undef') {
    notify { "check 1 not defined true \$dummy_undef = ${dummy_undef}": }
  } else {
    notify { "check 1 not defined false \$dummy_undef = ${dummy_undef}": }
  }
  if !defined("$dummy_undef") {
    notify { "check 2 not defined true \$dummy_undef = ${dummy_undef}": }
  } else {
    notify { "check 2 not defined false \$dummy_undef = ${dummy_undef}": }
  }
  if "$dummy_undef" == '' {
    notify { "check 3 interpolated empty true \$dummy_undef = ${dummy_undef}": }
  } else {
    notify { "check 3 interpolated empty false \$dummy_undef = ${dummy_undef}": }
  }
# NOTE:  uncmmenting the code below leads to catalog compialtion error: Error while evaluating a Function Call, 'defined' parameter 'vals' expects a value of type String or Type, got Undef 

#  if !defined($dummy_undef) {
#    notify { "check 4 not defined true \$dummy_undef = ${dummy_undef}": }
#  } else {
#    notify { "check 4 not defined false \$dummy_undef = ${dummy_undef}": }
#  }
#
#  if !defined('$dummy_defined') {
#    notify { "check 1 not defined true \$dummy_defined = ${dummy_defined}": }
#  } else {
#    notify { "check 1 not defined false \$dummy_defined = ${dummy_defined}": }
#  }

  if !defined("$dummy_defined") {
    notify { "check 2 not defined true \$dummy_defined = ${dummy_defined}": }
  } else {
    notify { "check 2 not defined false \$dummy_defined = ${dummy_defined}": }
  }
  if "$dummy_defined" == '' {
    notify { "check 3 interpolated empty true \$dummy_defined = ${dummy_defined}": }
  } else {
    notify { "check 3 interpolated empty false \$dummy_defined = ${dummy_defined}": }
  }
  if !defined($dummy_defined) {
    notify { "check 4 not defined true \$dummy_defined = ${dummy_defined}": }
  } else {
    notify { "check 4 not defined false \$dummy_defined = ${dummy_defined}": }
  }
}
#  Puppet run log:
#  
#  check 1 not defined false $dummy_undef = 
#  check 2 not defined true $dummy_undef = 
#  check 1 not defined false $dummy_defined = yes
#  check 2 not defined true $dummy_defined = yes
#  check 3 interpolated empty true $dummy_undef = 
#  check 3 interpolated empty false $dummy_defined = yes
