#!/bin/bash

string_remove_suffix(){
	local str="$1"
	local suf="$2"
	echo "${str%$suf}"
	return 0
}
string_has_suffix(){
	local str="$1"
	local suf="$2"
	local body="$(string_remove_suffix "$str" "$suf")"
	if [ "$str" != "$body" ] ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}
string_set_suffix(){
	local str="$1"
	local suf="$2"
	if [[ $(string_has_suffix "$str" "$suf") != 0 ]] ; then
		echo "$str"
	else
		echo "$str$suf"
	fi
	return 0
}


string_remove_prefix(){
	local str="$1"
	local pre="$2"
	echo "${str#$pre}"
	return 0
}
string_has_prefix(){
	local str="$1"
	local pre="$2"
	local body="$(string_remove_prefix "$str" "$pre")"
	if [ "$str" != "$body" ] ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}
string_set_prefix(){
	local str="$1"
	local pre="$2"
	if [[ $(string_has_prefix "$str" "$pre") != 0 ]] ; then
		echo "$str"
	else
		echo "$pre$str"
	fi
	return 0
}

