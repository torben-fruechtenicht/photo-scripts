#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r BUILD_TEMPLATES="$TESTDIR/../../profile-builder/build_templates.sh"

declare -r BASELINES_ROOT="$TESTDIR/baselines"
declare -r GENERATED_TEMPLATES_DIR="$TESTDIR/generated_templates"
declare -r BLANK_TEMPLATE="$TESTDIR/blank.pp3"

find "$GENERATED_TEMPLATES_DIR" -type f -name '*.pp3' -delete

"$BUILD_TEMPLATES" "$BLANK_TEMPLATE" "$GENERATED_TEMPLATES_DIR" "$BASELINES_ROOT"

echo "---"
find "$GENERATED_TEMPLATES_DIR" -type f -name '*.pp3'