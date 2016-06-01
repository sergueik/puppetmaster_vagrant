#!/usr/bin/bash
set -ue
################################################################################
#
# ssss (Similar to Serverspec by Shell)
#
#   network
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

