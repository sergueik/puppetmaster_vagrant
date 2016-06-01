#!/usr/bin/bash
set -ue
################################################################################
#
# ssss (Similar to Serverspec by Shell)
#
#   file
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

