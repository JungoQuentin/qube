#!/bin/sh
echo -ne '\033c\033]0;BCube\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/BCube.x86_64" "$@"
