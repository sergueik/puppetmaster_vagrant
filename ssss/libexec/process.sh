#!/usr/bin/bash
set -ue

function test_process() {

	if [[ $# -ne 1 ]]; then
		actual="invalid parameters -> usage : test_port <PORT>"
		return 1
	fi

	processname=$1

	actual=$(ps ax | grep -qie "[ /]${processname}" )

	if [ $? != 0 ]; then
		actual="${processname} not running"
		return 1
	fi
		actual="${processname} running"
	return 0
}

