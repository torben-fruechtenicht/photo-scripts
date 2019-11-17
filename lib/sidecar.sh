replace_in_sidecar() {
    local -r sidecar=$1
    local -r section=$2
    local -r property=$3
    local -r value=$4

    if sed -n '/\['"$section"'\]/,/^$/p' "$sidecar" | grep -q "$property"; then
        # if the entry already exists, just overwrite with new value
        test -v VERBOSE && echo "[INFO] UPDATE $section $property=$value" >&2        
        # https://unix.stackexchange.com/a/416126
        sed -i  '/\['"$section"'\]/,/^$/ s|^'"$property"=.*$'|'"$property"'='"$value"'|' "$sidecar"    
    elif (( $(sed -n '/\['"$section"'\]/,/^$/p' "$sidecar" | wc -l) > 2 )); then        
        # the section is only two lines long, i.e. there are no entries: just replace the whole section + added 
        # new entry
        test -v VERBOSE && echo "[INFO] ADD $section $property=$value (1st entry)" >&2
        sed -i '/\['"$section"'\]/ a '"$property"'='"$value"'' "$sidecar"
    else 
        # section has entries but not the current one
        test -v VERBOSE && echo "[INFO] ADD $section $property=$value" >&2
        sed -i 's|\['"$section"'\]|\['"$section"'\]\n'"$property"'='"$value"'|' "$sidecar"
    fi
}