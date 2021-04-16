#!/bin/sh
# based on: https://www.cyberforum.ru/shell/thread2812818.html#post15414974
find . -type f -name 'de*' -exec sh -c 'F=$0;printf "%s\t%s\n" $(stat -c %A $F) $(md5sum $F)' {} \;
