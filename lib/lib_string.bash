#!/bin/bash
source "lib_math.bash"
string_remove_suffix(){
	local str=$1
	local suf=$2
	echo "${str%$suf}"
	return 0
}
string_has_suffix(){
	local str=$1
	local suf=$2
	local body=$(string_remove_suffix "$str" "$suf")
	if [ "$str" != "$body" ] ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}
string_set_suffix(){
	local str=$1
	local suf=$2
	if (( "$(string_has_suffix "$str" "$suf")" != 0 )) ; then
		echo "$str"
	else
		echo "$str$suf"
	fi
	return 0
}


string_remove_prefix(){
	local str=$1
	local pre=$2
	echo "${str#$pre}"
	return 0
}
string_has_prefix(){
	local str=$1
	local pre=$2
	local body=$(string_remove_prefix "$str" "$pre")
	if [[ "$str" != "$body" ]] ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}
string_set_prefix(){
	local str=$1
	local pre=$2
	if (( "$(string_has_prefix "$str" "$pre")" != 0 )) ; then
		echo "$str"
	else
		echo "$pre$str"
	fi
	return 0
}

string_length(){
	local str=$1
	echo ${#str}
	return 0
}
string_sub(){
	local str=$1
	local start=$2
	local len=$3
	local strlen=$(string_length "$str")
	if [[ -z "$len" ]] ; then
		len=$strlen
	fi
	if (( $start < 0 )) ; then
		start=$(( $strlen + $start ))
	fi
	start=$(math_min $start $strlen)
	if (( $len < 0 )) ; then
		len=$(( $strlen + $len - $start  ))
	fi
	echo "${str:$start:$len}"
	return 0
}

# $1:source string
# $2:delimiter
# $3:name of dest array
string_split(){
	local _str=$1
	local IFS=$2
	local _dest=$3
	local _result=()
	set -- $_str
	_result=("$@")
	array_copy "_result" "$_dest"
	return 0	
}

# $1:source string
# $2:delimiter
# $3,4,5,... : name of dest vars
string_split_vars(){
	local _src=$1
	local IFS=$2
	shift 2
	local _names=("$@")
	set -- $_src
	for _name in "${_names[@]}" ; do
		eval "${_name}=\$1"
		shift
	done
	return 0
}



