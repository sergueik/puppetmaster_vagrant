#!/bin/bash
set -ue
################################################################################
#
# ssss (Similar to Serverspec by Shell)
#
################################################################################
# Copyright (c) 2015 nobrooklyn
#
# LICENSE : GNU LESSER GENERAL PUBLIC LICENSE Version. 3
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Lesser Public License for more details.
#  
#  You should have received a copy of the GNU General Lesser Public
#  License along with this program.  If not, see
#  <http://www.gnu.org/licenses/lgpl-3.0.html>.
#################################################################################

VERSION="0.0.1"

######
LIBEXEC_DIR=$(dirname $(readlink -f $0))
. ${LIBEXEC_DIR}/logger.sh
. ${LIBEXEC_DIR}/network.sh
. ${LIBEXEC_DIR}/fs.sh
. ${LIBEXEC_DIR}/user.sh
. ${LIBEXEC_DIR}/kernel.sh
. ${LIBEXEC_DIR}/file.sh


# counter
NUM_TESTCASE=0
NUM_OK=0
NUM_NG=0

######

function version() {
	echo "${VERSION}"
}

function banner() {
	echo "--------------------------------"
	echo "ssss version $(version)"
	echo "  Similar to ServerSpec by Shell"
	echo "--------------------------------"
	echo ""
}

function usage() {
	echo "$ ssss <test file>"
	echo ""
}

function bar() {
	echo "=================================================="
}

function run() {
	IFSBK=$IFS
	IFS=':'

	set -- $@

	IFS=$IFSBK

	local testcase="$(echo $2)"
	local method="test_${testcase}"
	local expected="$(echo $3)"

	local ret=

	${method} "${expected}" || ret=$?

	if [[ ${ret} -eq 0 ]]; then
		ok "case no.${NUM_TESTCASE} ${testcase}" "${expected}" "${actual}"
		NUM_OK=$((NUM_OK + 1))
	else
		ng "case no.${NUM_TESTCASE} ${testcase}" "${expected}" "${actual}"
		NUM_NG=$((NUM_NG + 1))
	fi
	actual=
}

######

banner

if [[ $# -eq 0 ]]; then
	usage
	exit 1
fi

if [[ ! -f ${1:-} ]]; then
	log "ERROR" "test file does not exisx. [file = ${1:-}]"
	exit 1
fi

TEST_FILE=$1

log "INFO" "begin test [file = ${TEST_FILE}]"

bar

while read testline
do
	NUM_TESTCASE=$((NUM_TESTCASE + 1))
	run "${testline}"
done < <(grep "^ *@test" ${TEST_FILE})

bar

RESULT="\e[32m OK \e[m"
RC=0

if [[ ${NUM_NG} -gt 0 ]]; then
	RESULT="\e[31m NG \e[m"
	RC=1
fi

log "${RESULT}" "run=${NUM_TESTCASE} ok=${NUM_OK} ng=${NUM_NG} end tests [file = ${TEST_FILE}]"

exit ${RC}

