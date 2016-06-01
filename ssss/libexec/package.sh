#!/usr/bin/bash
set -ue

function test_package_version() {

	if [[ $# -ne 2 ]]; then
		actual="invalid parameters -> usage : file_contatins <package_name> <expected_version>"
		return 1
	fi
  
	local package_name=$1
	local expected_version=$2
  
  actual=$(rpm -qa --queryformat '%{V}-%{R}' "${package_name}")
  
  if [[ -z ${actual} ]]; then
		actual="${package_name} not installed."
		return 1
	fi

	if [[ ${expected} != ${actual} ]]; then
    actual="${package_name} installed with version: ${actual}"
		return 1
	fi

	return 0
}