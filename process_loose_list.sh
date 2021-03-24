#!/bin/bash

VER='02'
APP='app_b'

APP_VER=$(printf "%s_%s" $APP $VER)

MODULES=$(cat <<EOF
Enabled:
app_a_02
app_b_01
app_b_03
app_b_05
app_c_03

Disabled:
app_a_01
app_b_02
app_b_04
app_b_06
app_c_01
app_c_02

EOF
)
ENABLED=$(echo -e "$MODULES" |sed -n '/Enabled:/,/^ *$/p' | sed '/Enabled/d')
DISABLED=$(echo -e "$MODULES" |sed -n '/Disabled:/,/^ *$/p' | sed '/Disabled/d')
echo -n 'Enabled Modules: '
for MODULE in $(echo -e "$ENABLED"); do
  echo $MODULE ' '
done
if echo -e "$ENABLED" | grep -q $APP_VER ; then
  echo "$APP_VER is already enabled"
else
  if echo -e "$DISABLED" | grep -q $APP_VER ; then
    echo "$APP_VER is currently disabled"
  else
    echo "$APP_VER is not intalled yet"
  fi  
fi
echo -n 'Disabled Modules: '
for MODULE in $(echo -e "$DISABLED"); do
  echo $MODULE ' '
done
echo -n "Modules to disable when enabling module $APP version $VER: "
for MODULE in $(echo -e "$ENABLED" | grep $APP | grep -v $APP_VER); do
  echo $MODULE ' '
done
