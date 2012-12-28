#!/bin/bash
here=$(cd $(dirname "$0");pwd)
export PATH="$here/../lib:$PATH"
source "lib_array.bash"
source "lib_debug.bash"

echo "=== join ==="
aaa=("aa aa" "bb  bb" "c")
echo "$(array_join aaa "+")"
echo "$(array_join aaa ":")"
echo "$(array_join aaa "")"

echo "=== split ==="
bbb="aa aa:bb  bb:c"
string_split "$bbb" ":" temp
debug_dump_args "${temp[@]}"
