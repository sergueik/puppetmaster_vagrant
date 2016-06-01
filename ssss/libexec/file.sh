#!/usr/bin/bash
set -ue

function test_file_contains() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : file_contatins <filepath>"
		return 1
	fi

	local filepath=$1
	local expected=$2

	if [[ ! -f ${filepath} ]]; then
		actual="file not exists -> ${filepath}"
		return 1
	fi

	actual=$(grep -e "${expected}" ${filepath})

	if [[ -z ${actual} ]]; then
		actual="not contains"
		return 1
	fi

	return 0
}

