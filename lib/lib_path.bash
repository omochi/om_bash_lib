#!/bin/bash
source "lib_string.bash"

#ディレクトリ部をスラッシュ付きで返す。無ければ空。
path_get_dir(){
	local path="$1"
	local dir=${path%/*}
	if [ "$dir" != "$path" ] ; then
		echo "$dir/"
	else
		echo ""
	fi
	return 0
}

path_get_base(){
	local path="$1"
	local base=${path##*/}
	echo "$base"
	return 0
}

#拡張子をドット付きで返す。無ければ空。
path_get_ext(){
	local base="$(path_get_base "$1")"
	local ext=${base##*.}
	if [ "$ext" != "$base" ] ; then
		echo ".$ext"
	else
		echo ""
	fi
	return 0
}

path_get_base_noext(){
	local base="$(path_get_base "$1")"
	echo "${base%.*}"
	return 0
}

path_remove_ext(){
	echo "$(path_get_dir "$1")$(path_get_base_noext "$1")"
	return 0
}

#拡張子変更
# $1 : path
# $2 : ext with dot
path_set_ext(){
	local ext="$2"
	echo "$(path_remove_ext "$1")$ext"
	return 0
}

#iOSの
path_is_at2x(){
	echo "$(string_has_suffix "$(path_remove_ext "$1")" "@2x")"
	return 0
}
path_set_at2x(){
	echo "$(string_set_suffix "$(path_remove_ext "$1")" "@2x")$(path_get_ext "$1")"
	return 0
}
path_remove_at2x(){
	echo "$(string_remove_suffix "$(path_remove_ext "$1")" "@2x")$(path_get_ext "$1")"
	return 0
}

