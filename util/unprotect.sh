__protected_file=

unprotected_file_if_needed() {
    local file=$1

    if [[ -w $file ]]; then
		echo "$file is not protected" >&2
        return
	fi

    if [[ -n $__protected_file ]] && [[ $__protected_file != $file ]]; then
        echo "[WARN] Dangling protected file $__protected_file" >&2
    elif [[ $__protected_file == $file ]]; then
        echo "[WARN] $file has already been unprotected" >&2
        return
    fi

    chmod u+w "$file"
    __protected_file=$file
}

reprotect_check_file() {
    local file=$1

    if [[ -z $__protected_file ]]; then
        return
    fi

    if [[ $__protected_file != $file ]]; then
        echo "[WARN] Dangling protected file $__protected_file, current file is $file" >&2
        exit 1
    fi

    chmod -w "$file"
    __protected_file=
}