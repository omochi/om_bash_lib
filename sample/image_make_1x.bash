#!/bin/bash
here=$(cd $(dirname "$0");pwd)
export PATH="$here/../lib:$PATH"
source "lib_image.bash"

if (( $# < 1 )) ; then
	echo "usage : $0 <dir>"
	exit 1
fi

dir="$1"

find "$dir" -name "*@2x*" | while read file ; do
	image_make_1x_from_2x "$file"
done
