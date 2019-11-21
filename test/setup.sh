declare -r TEST_DIR="$(dirname "$(readlink -e "$0")")"
declare -r PROJECT_ROOT="$TEST_DIR/../.."

declare -r INPUT_DIR="$TEST_DIR/input"
declare -r OUTPUT_DIR="$TEST_DIR/output"
declare -r EXPECTED_DIR="$TEST_DIR/expected"

(! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR") || find "$OUTPUT_DIR" -type f -delete

assert_actual_output_matches_expected() {
    cd "$EXPECTED_DIR" && find . -type f | while read -r expected_file; do

        if ! [[ -f "$OUTPUT_DIR/$expected_file" ]]; then
            echo "Expected file $expected_file missing"
            exit 1
        fi

        if ! cmp -s "$EXPECTED_DIR/$expected_file" "$OUTPUT_DIR/$expected_file"; then
            echo "Actual file does not match $expected_file"
            exit 1
        fi
    done
}

assert_correct_actual_sidecar_count() {
    local -r expected_count=$1    
    local -r actual_count=$(find "$OUTPUT_DIR" -type f -name '*.pp3' | wc -l)

    if (( $actual_count != $expected_count )); then
        echo "Not all or too many sidecars were created: $actual_count"
        exit 1
    fi
}