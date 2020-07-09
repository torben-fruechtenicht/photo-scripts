__quote_if_spaces_exist() {
	local -r keyword=$1
	# first test takes care of existing with blanks, these have quotes already
	if ! [[ $keyword =~ \".+\" ]] && [[ $keyword =~ .+[[:space:]].+ ]]; then
		echo "\"$keyword\""
	else
		echo $keyword
	fi	
}

sidecar_set_property() {
    local -r sidecar=$1
    local -r section=$2
    local -r property=$3
    local -r value=$4

    if sed -n '/\['"$section"'\]/,/^$/p' "$sidecar" | grep -q "$property="; then
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

# FIXME rename to add_iptc_keywords
sidecar_add_iptc_keywords() {
	local -r sidecar_file=$1
    local -r new_keywords=$2

	local keywords=

	local -r OLD_IFS=$IFS
	IFS=";"

	local old_keywords=$(sed -rn '/\[IPTC\]/,/^$/ s/Keywords=(.+)+$/\1/p' "$sidecar_file")
	for old_keyword in $old_keywords; do 
		if ! [[ $new_keywords =~ .*${old_keyword//[\"]/}\;.* ]]; then
			keywords="$keywords$old_keyword;"
		fi		
	done

	for new_keyword in $new_keywords; do
		keywords="$keywords$(__quote_if_spaces_exist "$new_keyword");"
	done

	IFS=$OLD_IFS

	if [[ -n $keywords ]]; then
		sidecar_set_property "$sidecar_file" "IPTC" "Keywords" "$keywords"
	fi
}