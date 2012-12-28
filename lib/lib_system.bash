#!/bin/bash

system_has_command(){
	local cmd="$1"
	which -s "$cmd"
	if [[ $? == 0 ]] ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}

