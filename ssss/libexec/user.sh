#!/bin/bash
set -ue

function test_user() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : user <username>"
		return 1
	fi

	local username=$1
	local expected=$2

	actual=$(grep "^${username}:" /etc/passwd | awk -F : '{print $3","$4","$6","$7}')

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

function test_group() {
	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : group <groupname>"
		return 1
	fi

	local groupname=$1
	local expected=$2

	actual=$(grep "^${groupname}:" /etc/group | awk -F : '{print $3}')

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

function test_ulimit() {
	# ulimit | limits.conf
	# --------------------
	# -c     | core - limits the core file size (KB)
	# -d     | data - max data size (KB)
	# -f     | fsize - maximum filesize (KB)
	# -l     | memlock - max locked-in-memory address space (KB)
	# -n     | nofile - max number of open file descriptors
	# -m     | rss - max resident set size (KB)
	# -s     | stack - max stack size (KB)
	# -t     | cpu - max CPU time (MIN)
	# -u     | nproc - max number of processes
	# -v     | as - address space limit (KB)
	#        | maxlogins - max number of logins for this user
	#        | maxsyslogins - max number of logins on the system
	#        | priority - the priority to run user process with
	# -x     | locks - max number of file locks the user can hold
	# -i     | sigpending - max number of pending signals
	# -q     | msgqueue - max memory used by POSIX message queues (bytes)
	# -e     | nice - max nice priority allowed to raise to values: [-20, 19]
	# -r     | rtprio - max realtime priority

	if [[ $# -ne 3 ]]; then
		actual="invalid parameters -> usage : ulimit <username> <key>"
		return 1
	fi

	local username=$1
	local key=
	local expected=$3

	case $2 in
		"core")       key="-c";;
		"data")       key="-d";;
		"fsize")      key="-f";;
		"memlock")    key="-l";;
		"nofile")     key="-n";;
		"rss")        key="-m";;
		"stack")      key="-s";;
		"cpu")        key="-t";;
		"nproc")      key="-u";;
		"as")         key="-v";;
		"locks")      key="-x";;
		"sigpending") key="-i";;
		"msgqueue")   key="-q";;
		"nice")       key="-e";;
		"rtprio")     key="-r";;
	esac
     
	if [[ -z ${key} ]]; then
		actual="invalid key -> $2"
		return 1
	fi

	actual=$(su - ${username} -c "ulimit ${key}")

	if [[ -z ${actual} ]]; then
		actual="not exists"
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
		return 1
	fi

	return 0
}

