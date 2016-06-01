#!/usr/bin/bash
set -ue

function test_sysctl() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : sysctl <key>"
		return 1
	fi

	local key=$1
	local expected=$2

	actual=$(sysctl -n ${key})

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

