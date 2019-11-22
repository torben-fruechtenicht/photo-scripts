#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"


declare -r BUILD_TEMPLATES="$PROJECT_ROOT/profile-builder/build_templates.sh"

declare -r BASELINES_ROOT="$INPUT_DIR/baselines"
declare -r GENERATED_TEMPLATES_DIR="$OUTPUT_DIR"
declare -r BLANK_TEMPLATE="$INPUT_DIR/blank.pp3"


"$BUILD_TEMPLATES" "$BLANK_TEMPLATE" "$OUTPUT_DIR" "$BASELINES_ROOT"


assert_actual_output_matches_expected "pp3"