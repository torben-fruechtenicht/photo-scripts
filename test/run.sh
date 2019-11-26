#! /usr/bin/env bash

declare -r TESTS_ROOT=$(dirname "$(readlink "$0")")
export VERBOSE=

find "$TESTS_ROOT" -type f -name 'test.sh' | sort | while read -r test_cmd; do
    echo 
    echo "=========================================================" 
    echo "Running $test_cmd"
    echo "=========================================================" 
    "$test_cmd"
    if (( $? == 0 )); then
        echo "-----"
        echo "[SUCCESS] All tests passed"
    else 
        echo "-----"
        echo "[FAIL] There were failures"
    fi
done