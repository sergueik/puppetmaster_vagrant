#!/bin/sh
pushd /uru
# TODO: prevent gems from installing to ~/.gem/ruby/2.1.0/gems
./uru_rt admin add ruby/bin
./uru_rt ls --verbose
./uru_rt gem list
./uru_rt ruby ruby/lib/ruby/gems/2.1.0/gems/rake-10.1.0/bin/rake spec
