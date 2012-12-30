#!/bin/bash
source "lib_string.bash"

path_get_base(){
	echo "${1##*/}"
	return 0
}

#ディレクトリ部をスラッシュ付きで返す。無ければ空。
path_get_dir(){
	local path=$1
	local base=$(path_get_base "$path")
	echo "$(string_sub "$path" 0 $(( $(string_length "$path") - $(string_length "$base") )) )"
	return 0
}

path_get_base_no_ext(){
	local base=$(path_get_base "$1")
	echo "${base%.*}"
	return 0
}

path_remove_ext(){
	echo "$(path_get_dir "$1")$(path_get_base_no_ext "$1")"
	return 0
}

#拡張子をドット付きで返す。無ければ空。
path_get_ext(){
	local path=$1
	local remove=$(path_remove_ext "$path")
	echo "$(string_sub "$path" $(string_length "$remove") )"
	return 0
}

#拡張子変更
# $1 : path
# $2 : ext with dot
path_set_ext(){
	echo "$(path_remove_ext "$1")$2"
	return 0
}

#何段拡張子なのか
path_count_ext(){
	local path=$1
	local remove=""
	local i=0
	while true ; do
		remove=$(path_remove_ext "$path")
		if [[ "$path" == "$remove" ]] ; then
			break
		fi
		path=$remove
		i=$((i+1))
	done
	echo "$i"
	return 0
}

#多段拡張子での操作
# $1 : path
# $2 : level 
# hoge.tar.gzなら、0:hoge.tar , 1:hoge , 2:hoge, ...
path_remove_multi_ext(){
	local path=$1
	local lv=$2
	local i=0
	while ((i<=lv)) ; do
		path=$(path_remove_ext "$path")
		i=$((i+1))
	done
	echo "$path"
	return 0
}

# hoge.tar.gzなら、0:.gz , 1:.tar , 2:(empty)
path_get_multi_ext(){
	local path=$(path_remove_multi_ext "$1" $(($2-1))  )
	echo "$(path_get_ext "$path")"
	return 0
}
path_get_base_no_multi_ext(){
	local base=$(path_get_base "$1")
	echo "$(path_remove_multi_ext "$base" $2)"
	return 0
}
# $1 : path
# $2 : level
# $3 : ext with dot
path_set_multi_ext(){
	echo "$(path_remove_multi_ext "$1" $2)$3"
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

path_safe_mkdir(){
	if [[ -d "$1" ]] ; then
		return 0
	fi
	mkdir -p "$1"
	return $?
}

path_safe_rmdir(){
	if [[ ! -e  "$1" ]] ; then
		return 0
	fi
	rm -rf "$1"
	return $?
}

path_is_git_inited(){
	if [[ ! -d "$1" ]] ; then
		echo "0"
		return 0
	fi

	pushd "$1" >/dev/null
	git status >/dev/null 2>&1
	echo $(( ! $? ))
	popd > /dev/null
	return 0
}

path_is_image_file(){
	if [[ ! -f "$1" ]] ; then
		echo "0"
		return 0
	fi
	mime=$(file -b --mime-type "$1")
	echo $(string_has_prefix "$mime" "image/")
}
