#! /usr/bin/env bash

set -eu

declare -r BASE_DIR=$(dirname "$(readlink -e "$0")")
TOOL_CMD="$BASE_DIR/tools//move_to_album"
GUI_CMD="$BASE_DIR/apps/move"

declare -r OPTIONAL_USE_GUI_PARAM=${1+$1}
if [[ -n $OPTIONAL_USE_GUI_PARAM ]] && [[ $OPTIONAL_USE_GUI_PARAM = "-g" ]]; then
    shift 1
    "$GUI_CMD" "$@"
else
    "$TOOL_CMD" "$@"
fi