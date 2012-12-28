#!/bin/bash
echo_eval(){
	local cmd="$1"
	echo "$cmd"
	eval "$cmd"
	return $?
}
