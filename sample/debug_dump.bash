#!/bin/bash
here=$(cd $(dirname "$0");pwd)
export PATH="$here/../lib:$PATH"
source "lib_debug.bash"

echo "=== debug_dump_var ==="
debug_dump_var "a b  c"
debug_dump_var "IFS=[$IFS]"

echo "=== debug_dump_args ==="
debug_dump_args "a a a" "b b b"
