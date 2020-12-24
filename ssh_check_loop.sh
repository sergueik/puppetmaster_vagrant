#!/bin/sh

# handy iterator for data infentory for a set of nodes protected with 2FA ssh

TARGETLIST='nodes.txt'
# NOTE: add an 'echo' in front of ssh to observe loop logic is right
if [[ -z "$U" ]] ; then
  U=$(whoami)
fi
INTERVAL=10
# RSA SSO requirement forces one to wait for next key, typically 30 sec

COUNT=$(wc -l $TARGETLIST| cut -f 1 -d ' ')

# NON-WORKING with some sshd (e.g. BoKS)
echo "Repeat $COUNT times"
cat $TARGETLIST | while read H ; do
  ( ssh $U@$H sh -c "hostname -f; hostname -i; sleep $INTERVAL;  exit 0" ; )
done
# NOTE: does not repeat

# WORKING
echo "Repeat $COUNT times"
for H in $(cat $TARGETLIST)  ; do ssh $U@$H sh -c 'hostname -f; hostname -i; exit 0' ; sleep $INTERVAL;done

