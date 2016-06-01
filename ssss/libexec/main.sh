#!/bin/bash
set -ue


VERSION="0.0.1"

######
LIBEXEC_DIR=$(dirname $(readlink -f $0))
. ${LIBEXEC_DIR}/logger.sh
. ${LIBEXEC_DIR}/network.sh
. ${LIBEXEC_DIR}/fs.sh
. ${LIBEXEC_DIR}/user.sh
. ${LIBEXEC_DIR}/kernel.sh
. ${LIBEXEC_DIR}/file.sh
. ${LIBEXEC_DIR}/process.sh
. ${LIBEXEC_DIR}/port.sh
. ${LIBEXEC_DIR}/package.sh

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


