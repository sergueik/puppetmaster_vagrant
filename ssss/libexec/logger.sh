#!/usr/bin/bash
set -ue

function now() {
	date "+%Y-%m-%dT%H:%M:%S"
}

function log() {
	echo -e "$(now) [$1] $2"
}

function ok() {
	log "\e[32m OK \e[m" "$1 [ expected = $2 | actual = $3 ]"
}

function ng() {
	log "\e[31m NG \e[m" "$1 [ expected = $2 | actual = $3 ]"
}

