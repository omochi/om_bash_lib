#!/bin/bash

# $1:name of source array
# $2:name of dest array
array_copy(){
	local _src=$1
	local _dest=$2
	eval "$_dest=(\"\${$_src[@]}\")"
	return 0
}

# $1:name of array
# $2:item
array_push(){
	local _name="$1"
	local _array=()
	array_copy "$_name" "_array"
	_array=("${_array[@]}" "$2")
	array_copy "_array" "$_name"
	return 0
}

# $1:name of source array
# $2:glue 
# 逆変換はlib_string.bash
array_join(){
	local _name=$1
	local IFS=$2
	local _array=()
	array_copy "$_name" "_array"
	echo "${_array[*]}"
	return 0
}

