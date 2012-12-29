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

image_im_draw_image(){
	echo "-draw 'image $1 $2,$3 $4,$5 \"$6\"'"
	return 0
}
image_im_draw_line(){
	echo "-draw 'line $1,$2 $3,$4'"
	return 0
}

# 9patch用の画像の下地を作る
# $1:貼り付ける画像パス
# $2:貼り付ける画像の幅
# $3:貼り付ける画像の高さ
image_im_npatch_base(){
	local image_path="$1"
	local image_width="$2"
	local image_height="$3"
	local code="convert -size $((image_width+2))x$((image_height+2)) canvas: -alpha transparent"
	code="$code $(image_im_draw_image SrcOver 1 1 $image_width $image_height "$image_path")" 
	code="$code -stroke black -strokewidth 0"
	echo "$code"
	return 0
}

# $1:画像の幅
# $2:画像の高さ
# $3,4,5,6:top,left,bottom,right
image_im_npatch_resize_inset(){
	local w=$1
	local h=$2
	local to=$3
	local le=$4
	local bo=$5
	local ri=$6
	local code=""
	code="$code $(image_im_draw_line $((1+le)) 0 $((1+w-ri-1)) 0)"
	code="$code $(image_im_draw_line 0 $((1+to)) 0 $((1+h-bo-1)))"
	echo "$code"
	return 0
}

image_im_npatch_content_inset(){
	local w=$1
	local h=$2
	local to=$3
	local le=$4
	local bo=$5
	local ri=$6
	local code=""
	code="$code $(image_im_draw_line $((1+le)) $((1+h)) $((1+w-ri-1)) $((1+h)) )"
	code="$code $(image_im_draw_line $((1+w)) $((1+to)) $((1+w)) $((1+h-bo-1)) )"
	echo "$code"
	return 0
}

# $1:source image path
# $2:output npatch image path
# $3,4,5,6:resize inset,top,left,bottom,right
# $7,8,9,10:content inset(optional)
image_make_npatch(){
	local src="$1"
	local out="$2"
	local rt="$3"
	local rl="$4"
	local rb="$5"
	local rr="$6"
	local ct="$7"
	local cl="$8"
	local cb="$9"
	local cr="${10}"
	local w=$(image_get_width "$src")
	local h=$(image_get_height "$src")
	local code=""
	
	code="$code $(image_im_npatch_base "$src" $w $h)"
	code="$code $(image_im_npatch_resize_inset $w $h $rt $rl $rb $rr)"
	if [[ -n $cr ]] ; then
		code="$code $(image_im_npatch_content_inset $w $h $ct $cl $cb $cr)"
	fi
	code="$code \"$out\""
	echo_eval "$code"
	return $?
}

