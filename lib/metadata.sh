function fullname_from_filename() {
    local -r basename=$(basename "$1")
    echo "${basename%%.*}"
}