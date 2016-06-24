 

The directory contains a trimmed down 'windows_spec_helper.rb':
require 'serverspec'

set :backend, :cmd


and a stock Rakefile with just one modification:

  t.rspec_opts = "--format documentation \
--format html --out reports/report_#{$host}.html \
 --format json --out reports/report_#{$host}.json"

to enforce file logging the ‘local’ directory can contain arbitrary number of spec files, and a bootstrapper script which basically calls
```
uru_rt.exe admin add ruby\bin
uru_rt.exe ruby ${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake spec
```

The `uru` module contains a basic serverspec  file that is run as a smoke test, but any real serverspec files can be dropped into the `local` folder and will run automatically.  Few real serverspec files from existing LP modules have been put to the instance and run successfully.



One still has to implement some tool to parse the json and determine what happened. i guess it may deserve some special handling better than printing to std out but i do not have anything





