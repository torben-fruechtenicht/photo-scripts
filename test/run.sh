#! /usr/bin/env bash

declare -r TESTS_ROOT=$(dirname "$(readlink "$0")")
export VERBOSE=

find "$TESTS_ROOT" -type f -name 'test.sh' | sort | while read -r test_cmd; do
    echo 
    echo "=========================================================" 
    echo "Running $test_cmd"
    echo "=========================================================" 
    "$test_cmd"
    echo "-----"
    if (( $? == 0 )); then
        echo "[SUCCESS] All tests from $(dirname "$test_cmd") passed"
    else 
        echo "[FAIL] There were failures in $(dirname "$test_cmd")"
        declare failures_exist=
    fi
done

echo -e "\n====="
if [[ -v failures_exist ]]; then
    echo "[FAIL] There were failed tests" 
else
    echo "[SUCCESS] All tests passed"
 fi