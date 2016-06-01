#!/usr/bin/bash
set -ue

function test_directory() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : directory <dirpath>"
		return 1
	fi

	local dirpath=$1
	local expected=$2

	actual=$(find ${dirpath} -type d -maxdepth 0 -printf "%u,%g,%m\n")

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

function test_file() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : file <dirpath>"
		return 1
	fi

	local dirpath=$1
	local expected=$2

	actual=$(find ${dirpath} -type f -maxdepth 0 -printf "%u,%g,%m\n")

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

function test_symbolic_link() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : symbolic_link <dirpath>"
		return 1
	fi

	local linkpath=$1
	local expected=$2

	actual=$(find ${linkpath} -type l -maxdepth 0 -printf "%l\n")

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}


