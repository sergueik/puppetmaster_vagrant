#!/usr/bin/bash
set -ue
################################################################################
#
# ssss (Similar to Serverspec by Shell)
#
#   file system
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

