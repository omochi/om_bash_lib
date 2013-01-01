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
	echo $(( 	$(image_get_width "$1") == $2 && \
				$(image_get_height "$1") == $3 ))
	return 0
}

# 画像のサイズが2の倍数か
image_size_is_even(){
	echo $(( $(image_get_width "$1") % 2 == 0 && $(image_get_height "$1") % 2 == 0 ))
	return 0
}

# 半分画像の存在をチェック
image_exists_1x_with_2x(){
	local path1x="$(path_remove_at2x "$1")"
	[[ -f "$path1x" ]] ; echo $(( ! $? ))
	return 0
}

# 半分画像のサイズをチェック
image_check_1x_size_with_2x(){
	local path2x="$1"	
	echo $(image_check_size "$(path_remove_at2x "$path2x")" \
		$(( $(image_get_width "$path2x") / 2)) $(( $(image_get_height "$path2x") /2)) )
	return 0
}

# 半分画像を作る
# $1 : at2x image path
# $2 : at1x image output path
# 特にエラーチェック等しない
image_make_1x_with_2x(){
	local src=$1 out=$2
	local w2=$(image_get_width "$src")
	local h2=$(image_get_height "$src")

	local code=$(image_im_resize_image "$src" "$out" $((w2/2)) $((h2/2)))
	echo_eval "$code"
	return $?
}


image_resize_image(){
	echo_eval "$(image_im_resize_image "$1" "$2" "$3" "$4")"
	return $?
}

# $1 : src path
# $2 : out path
# $3 : new width
# $4 : new height
image_im_resize_image(){
	#サイズに!を付けると指定サイズになる。
	#そうでない場合は縦横比維持が働く
	echo "convert -resize ${3}x${4}! '$1' '$2'"
	return 0
}

image_im_draw_image(){
	echo "-draw 'image $1 $2,$3 $4,$5 \\'$6\\' ' "
	return 0
}
image_im_draw_line(){
	echo "-draw 'line $1,$2 $3,$4'"
	return 0
}

# 9patch用の画像の下地を作る
# $1:貼り付ける画像パス
image_im_npatch_base(){
	local code="convert '$1' -bordercolor none -border 1 "
	echo "$code"
	return 0
}

# $1:画像の幅
# $2:画像の高さ
# $3,4,5,6:top,left,bottom,right
image_im_npatch_resize_inset(){
	local w=$1 h=$2 t=$3 l=$4 b=$5 r=$6
	local code="-stroke black -strokewidth 0"
	if (( $l!=-1 && $r!=-1 )) ; then
		code="$code $(image_im_draw_line $((1+l)) 0 $((1+w-r-1)) 0)"
	fi
	if (( $t!=-1 && $b!=-1 )) ; then
		code="$code $(image_im_draw_line 0 $((1+t)) 0 $((1+h-b-1)))"
	fi
	echo "$code"
	return 0
}

image_im_npatch_content_inset(){
	local w=$1 h=$2 t=$3 l=$4 b=$5 r=$6
	local code="-stroke black -strokewidth 0"
	if (( $l!=-1 && $r!=-1 )) ; then
		code="$code $(image_im_draw_line $((1+l)) $((1+h)) $((1+w-r-1)) $((1+h)) )"
	fi
	if (( $t!=-1 && $b!=-1 )) ; then
		code="$code $(image_im_draw_line $((1+w)) $((1+t)) $((1+w)) $((1+h-b-1)) )"
	fi
	echo "$code"
	return 0
}

# $1:source image path
# $2:output npatch image path
# $3,4,5,6:resize inset,top,left,bottom,right(optional)
# $7,8,9,10:content inset(optional)
# -1だとラインが引かれない
image_make_npatch(){
	local src=$1 out=$2 
	local rt=$3 rl=$4 rb=$5 rr=$6
	local ct=$7 cl=$8 cb=$9 cr=${10}
	local w=$(image_get_width "$src")
	local h=$(image_get_height "$src")
	local code=""

	code="$code $(image_im_npatch_base "$src")"
	code="$code $(image_im_npatch_resize_inset  $w $h ${rt:--1} ${rl:--1} ${rb:--1} ${rr:--1})"
	code="$code $(image_im_npatch_content_inset $w $h ${ct:--1} ${cl:--1} ${cb:--1} ${cr:--1})"
	
	code="$code '$out'"
	echo_eval "$code"
	return $?
}

# 9patchから画像部分を取り出す
# $1:source path
# $2:output path
image_decompose_npatch(){
	echo_eval "convert '$1' -shave 1x1 '$2'"
	return $?
}

# $1:source path
# $2,3,4,5:left,top,width,height
image_read_pixels_with_rect(){
	local cmd="convert '$1' -crop ${4}x${5}+${2}+${3} txt:-"
	cmd="$cmd | tail -n +2 | tr -cs '0-9\n' ' ' "
	eval "$cmd"
	return $?
}

# 9patchの黒帯部分のimage_read_pixels_with_rectの結果を読む
image_read_npatch_bar_pixel_data(){
	local x=0 y=0 r=0 g=0 b=0 a=0 junk
	local i=0
	local count=0
	local begin=-1
	local end=-1
	local tail=-1

	while read x y r g b a junk ; do
		if (( a != 0 )) ; then
			if (( begin == -1 )) ; then
				begin=$i
			fi
			end=$i
		fi
		i=$((i+1))
	done
	count=$i
	if (( end != -1 )) ; then
		tail=$((count-end-1))
	fi
	echo "$begin $tail"
	return 0
}

# $1:source path
# バーが無ければ-1になる
image_read_npatch_resize_inset(){
	local src=$1
	local w=$(image_get_width "$src")
	local h=$(image_get_height "$src")
	local top_bar=$(image_read_pixels_with_rect "$src" 1 0 $((w-2)) 1 | image_read_npatch_bar_pixel_data)
	local left_bar=$(image_read_pixels_with_rect "$src" 0 1 1 $((h-2)) | image_read_npatch_bar_pixel_data)
	local t l b r
	string_split_vars "$left_bar" ' ' t b
	string_split_vars "$top_bar" ' ' l r
	echo "$t $l $b $r"
	return 0
}

image_read_npatch_content_inset(){
	local src=$1
	local w=$(image_get_width "$src")
	local h=$(image_get_height "$src")
	local bottom_bar=$(image_read_pixels_with_rect "$src" 1 $((h-1)) $((w-2)) 1 | image_read_npatch_bar_pixel_data)
	local right_bar=$(image_read_pixels_with_rect "$src" $((w-1)) 1 1 $((h-2)) | image_read_npatch_bar_pixel_data)
	local t l b r
	string_split_vars "$right_bar" ' ' t b
	string_split_vars "$bottom_bar" ' ' l r
	echo "$t $l $b $r"
	return 0
}

# -1なら素通り
# $1 : src value
# $2 : src size
# $3 : dest size
image_resize_npatch_scale_margin(){
	if (( $1==-1 ))  ; then
		echo $1
		return
	fi
	echo $(( $1*$3/$2 ))
	return
}

# $1 : source path
# $2 : dest path
# $3 : working temp dir path
# $4,5 : resize width,height omitted bar pixel
image_resize_npatch(){
	local src=$1
	local dest=$2
	local tmp=$3
	local dw=$4
	local dh=$5
	local sw=$(( $(image_get_width "$src")  - 2 ))
	local sh=$(( $(image_get_height "$src") - 2 ))
	local rt rl rb rr ct cl cb cr
	string_split_vars "$(image_read_npatch_resize_inset "$src")" ' ' rt rl rb rr
	string_split_vars "$(image_read_npatch_content_inset "$src")" ' ' ct cl cb cr
	
	# リサイズ後のマージン情報を計算、無い場合の-1は-1のまま
	rt=$(image_resize_npatch_scale_margin $rt $sh $dh)
	rl=$(image_resize_npatch_scale_margin $rl $sw $dw)
	rb=$(image_resize_npatch_scale_margin $rb $sh $dh)
	rr=$(image_resize_npatch_scale_margin $rr $sw $dw)
	ct=$(image_resize_npatch_scale_margin $ct $sh $dh)
	cl=$(image_resize_npatch_scale_margin $cl $sw $dw)
	cb=$(image_resize_npatch_scale_margin $cb $sh $dh)
	cr=$(image_resize_npatch_scale_margin $cr $sw $dw)

	local decomp_src=$(mktemp "$tmp/decomp_src.XXXXXX")
	local decomp_resize=$(mktemp "$tmp/decomp_resize.XXXXXX")

	# パッチを剥がす
	image_decompose_npatch "$src" "$decomp_src"
	# リサイズする
	image_resize_image "$decomp_src" "$decomp_resize" $dw $dh
	# パッチを付ける
	image_make_npatch "$decomp_resize" "$dest" $rt $rl $rb $rr $ct $cl $cb $cr	
	return $?
}



