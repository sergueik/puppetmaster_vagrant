#!/usr/bin/bash
set -ue

function test_port() {

	if [[ $# -ne 1 ]]; then
		actual="invalid parameters -> usage : test_port <PORT>"
		return 1
	fi

	local_port=$1
	#  protocol=$2
 
  netstat -tunl | grep -- ":${local_port}" >& /dev/null

	if [ $? != 0 ]; then
		actual="${local_port} not listened"
		return 1
	fi
		actual="${local_port} listened"
	return 0
}


