# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 
$product_name = hiera('product_name')
validate_string($product_name)
notify{$product_name:}
$product_specific_params  = hiera_hash('product_specific_params')
validate_hash($product_specific_params)

# with yum do not need to explicitly install dependency RPMs, 
# only the RPM packages with the desired CPAN modules:
}
