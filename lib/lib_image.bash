#!/bin/bash
source "lib_system.bash"
source "lib_path.bash"
source "lib_eval.bash"
if (( ! $(system_has_command "convert") || ! $(system_has_command "identify") )) ; then
	echo "ImageMagick is not installed" >&2
	exit 1
fi

image_get_width(){
	echo $(identify -format "%w" "$1")
	return 0
}
image_get_height(){
	echo $(identify -format "%h" "$1")
	return 0
}

# $1:image path
# $2:width
# $3:height
image_check_size(){
	if (( $(image_get_width "$1") == "$2" && $(image_get_height "$1") == "$3" )) ; then
		echo "1"
	else
		echo "0"
	fi
	return 0
}

# 半分のをつくる
# 既にあったら作らない
# 既にあったのが変ならエラー
# $1:at2x image path
image_make_1x_from_2x(){
	local path="$1"
	local path1x="$(path_remove_at2x "$path")"
	
	local w2=$(image_get_width "$path")
	local h2=$(image_get_height "$path")

	if (( $w2 % 2 != 0 || $h2 % 2 != 0 )) ; then
		echo "image $path(${w2}x${h2}) is not even size" >&2
		return 1
	fi

	local w1=$(($w2 / 2))
	local h1=$(($h2 / 2))
	if [ -e "$path1x" ] ; then
		if (( $(image_check_size "$path1x" $w1 $h1) )) ; then
			return 0
		else
			echo "image $path1x is not half of $path ; please delete it" >&2
			return 1
		fi
	fi
	
	echo_eval "convert -resize ${w1}x${h1} \"$path\" \"$path1x\"" 	
	return $?	
}





