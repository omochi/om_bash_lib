#!/bin/bash

# $1:name of source array
# $2:name of dest array
array_copy(){
	local src="$1"
	local dest="$2"
	eval "$dest=(\"\${$src[@]}\")"
	return 0
}

# $1:name of array
# $2:item
array_push(){
	local name="$1"
	local array=()
	array_copy "$name" "array"
	array=("${array[@]}" "$2")
	array_copy "array" "$name"
	return 0
}

# $1:name of source array
# $2:glue 
# 逆変換はlib_string.bash
array_join(){
	local name="$1"
	local IFS="$2"
	local array=()
	array_copy "$name" "array"
	echo "${array[*]}"
	return 0
}

