declare -r TEST_DIR="$(dirname "$(readlink -e "$0")")"
declare -r PROJECT_ROOT="$TEST_DIR/../.."

declare -r INPUT_DIR="$TEST_DIR/input"
declare -r OUTPUT_DIR="$TEST_DIR/output"
declare -r EXPECTED_DIR="$TEST_DIR/expected"

(! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR") || find "$OUTPUT_DIR" -type f -delete  

assert_actual_output_matches_expected() {
    local -r filetype=$1
    cd "$EXPECTED_DIR" && find . -type f ${filetype+-name '*.'$filetype} | while read -r expected_file; do

        if ! [[ -f "$OUTPUT_DIR/$expected_file" ]]; then
            echo "[FAIL] Expected file $expected_file missing"
            exit 1
        fi

        # cmp does a byte-wise check
        if ! cmp -s "$OUTPUT_DIR/$expected_file" "$EXPECTED_DIR/$expected_file"; then
            echo -e "[FAIL] Actual file does not match expected $expected_file:\n$(diff "$OUTPUT_DIR/$expected_file" "$EXPECTED_DIR/$expected_file")"
            exit 1
        fi
    done
}

assert_correct_actual_sidecar_count() {
    local -r expected_count=$1    
    local -r actual_count=$(find "$OUTPUT_DIR" -type f -name '*.pp3' | wc -l)

    if (( $actual_count != $expected_count )); then
        echo "[FAIL] Not all or too many sidecars were created: $actual_count"
        exit 1
    fi
}

assert_created_files_match_expected() {

    if ! [[ -f "$EXPECTED_DIR/files" ]]; then
        echo "[FAIL] $EXPECTED_DIR/files missing"
        exit 1
    fi

    if ! cmp -s "$EXPECTED_DIR/files" <(cd "$OUTPUT_DIR" && find . -mindepth 1 | sort); then
        local diff_result=$(diff "$EXPECTED_DIR/files" <(cd "$OUTPUT_DIR" && find . -mindepth 1 | sort))
        echo -e "[FAIL] Actual files do not match expected:\n$diff_result" 
        exit 1
    fi
}