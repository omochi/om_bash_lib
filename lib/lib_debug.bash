#!/bin/bash

debug_dump_var(){
	local value="$1"
	echo "$value (" $(echo -n "$value" | od -v -A n -t x1) ")"
	return 0
}
debug_dump_args(){
	local i=1
	while [ -n "$1" ] ; do
		echo "arg[$i]=$(debug_dump_var "$1")"
		shift
		i=$(( i + 1 ))
	done
	return 0
}
