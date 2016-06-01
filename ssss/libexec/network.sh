#!/usr/bin/bash
set -ue

function test_ip_address() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : ip_address <interface>"
		return 1
	fi

	local interface=$1
	local expected=$2

	actual=$(ip addr show ${interface} | grep inet | grep -v inet6 | awk '{print $2}')

	if [[ -z ${actual} ]]; then
		actual="not exsits"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

# TODO : options 
function test_hostname() {
	local expected=$1
	actual=$(hostname)

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

function test_hosts() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : hosts <hostname>"
		return 1
	fi

	local hostname=$1
	local expected=$2

	actual=$(grep ${hostname} /etc/hosts | awk '{print $1}')

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}


