STATEDIR='<%= @statedir >'
STATEDIR='dummy'
if [ "$STATEDIR" = "" ]; then
  STATEDIR=$(/opt/puppetlabs/puppet/bin/puppet config print statedir)
fi
LOG_FILE='last_run_report.yaml'
if [ -d $STATEDIR ] ; then
  pushd "$STATEDIR"
  if [ -f $LOG_FILE ] ; then
    FILE_COUNT=$(ls -1 $LOG_FILE.* | wc -l)
    if [ $FILE_COUNT -gt 0  ] ; then
      echo "FILE_COUNT=${FILE_COUNT}"
      CNT=$FILE_COUNT
      while [ $CNT -gt 0  ] ; do
        NEXT_CNT=$(expr $CNT + 1)
        >&2 echo "cp $LOG_FILE.$CNT $LOG_FILE.$NEXT_CNT"
        cp $LOG_FILE.$CNT $LOG_FILE.$NEXT_CNT
        CNT=$(expr $CNT - 1)
      done
    fi
    cp $LOG_FILE "${LOG_FILE}.1"
  fi
  popd
fi
