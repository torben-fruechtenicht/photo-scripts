quote_if_spaces_exist() {
	local -r keyword=$1
	if [[ $keyword =~ .+[[:space:]].+ ]]; then
		echo "\"$keyword\""
	else
		echo $keyword
	fi	
}

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

set_iptc_in_sidecar() {
	local -r sidecar_file=$1
    local -r keywords=$2

	local new_keywords=

	local -r OLD_IFS=$IFS
	IFS=";"

	local old_keywords=$(sed -rn '/\[IPTC\]/,/^$/ s/Keywords=(.+)+$/\1/p' "$sidecar_file")
	for old_keyword in "$old_keywords"; do 
		if ! [[ $keywords =~ .*${old_keyword//[\"]/}\;.* ]]; then
			new_keywords="$new_keywords$old_keyword;"
		fi		
	done

	for new_keyword in "$keywords"; do
		new_keywords="$new_keywords$(quote_if_spaces_exist "$new_keyword");"
	done

	IFS=$OLD_IFS

	if [[ -n $new_keywords ]]; then
		replace_in_sidecar "$sidecar_file" "IPTC" "Keywords" "$new_keywords"
	fi
}