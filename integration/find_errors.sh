#!/bin/bash
if [ -z "${DEBUG}" ]; then
  DEBUG=false
  1>&2 echo 'Setting DEBUG to ' $DEBUG
fi
ERROR_MESSAGES=('Wait forPuppet status not applying on ' 'Could not discover any nodes from' 'Caught TERM' 'cannot find zipfile directory' 'Internal Server Error' 'Failed to start' 'Failed to Stop')
PATTERN=$(printf "|%s" "${ERROR_MESSAGES[@]}")
# chomp the leading '|' separator
PATTERN=${PATTERN:1}
PATTERN="(${PATTERN})"
if $DEBUG ; then
  1>&2 echo "PATTERN=\"${PATTERN}\""
fi
LOG_DIRS='/tmp/logdirs.txt'
USER1='vagrant'
USER2='vagrant'
USER3='root'
DUMMY_FILE='dummy'
if [ -e $LOG_DIRS ]
then
  if $DEBUG ; then
    1>&2 echo "Using provided \"${LOG_DIRS}\""
  fi
else
  if $DEBUG ; then
    1>&2 echo "Creating \"${LOG_DIRS}\""
  fi
  touch $LOG_DIRS
  for LOG_DIR in $(find '.' -maxdepth 1 -type d -and -newer $DUMMY_FILE -and -name '*' -and \( -user $USER1 -or -user $USER2 -or -user $USER3 \));
  # NOTE: find: ‘vagrant’ is not the name of a known user
  do
    if [[ $LOG_DIR != '.' ]]
    then
      echo $LOG_DIR|tee -a $LOG_DIRS
    fi
  done
  while read LOG_DIR ; do
    if [[ -d $LOG_DIR ]]
      >/dev/null pushd $LOG_DIR
      for LOG_FILE in $(ls -1)
      do
        grep -Ei "${PATTERN}" $FILE
        if [[ $? -eq  0 ]]
        then
          echo $FILE
          for ERROR_MESSAGE in $ERROR_MESSAGES
          do
            grep -i "${ERROR_MESSAGE}" $FILE
          done
        fi
      done
      >dev/null popd
    fi
  done < $LOG_DIRS
  if $DEBUG ; then
    1>&2 echo "Removing \"${LOG_DIRS}\""
  fi
  rm -f $LOG_DIRS
fi	

