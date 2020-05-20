#! /usr/bin/env bash

set -eu

declare -r BASE_DIR=$(dirname "$(readlink -e "$0")")
TOOL_CMD="$BASE_DIR/tools//move_to_album"
GUI_CMD="$BASE_DIR/apps/move"

while getopts "g" opt; do
    case $opt in
        g ) declare -r USE_GUI=;;
	esac
done
shift $(expr $OPTIND - 1)

if [[ -v USE_GUI ]]; then
    "$GUI_CMD" "$@"
else
    "$TOOL_CMD" "$@"
fi