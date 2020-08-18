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

sidecar_add_iptc_keywords() {
	local -r sidecar_file=$1
    local -r new_keywords=$2

	! test -e "$sidecar_file" && return
	test -z "$new_keywords" && return

	local keywords=

	local -r OLD_IFS=$IFS
	IFS=";"

	local old_keywords=$(sed -rn '/\[IPTC\]/,/^$/ s/Keywords=(.+)+$/\1/p' "$sidecar_file")
	for old_keyword in $old_keywords; do 
		if ! [[ $new_keywords =~ .*${old_keyword//[\"]/}\.* ]]; then
			keywords="$keywords$old_keyword;"
		fi		
	done

	for new_keyword in $new_keywords; do
		keywords="$keywords$(quote "$new_keyword");"
	done

	IFS=$OLD_IFS

	if [[ -n $keywords ]]; then
		sidecar_set_property "$sidecar_file" "IPTC" "Keywords" "$keywords"
	fi
}

sidecar_remove_iptc_keywords() {
	local -r sidecar_file=$1
    local -r keywords=$2

	! test -e "$sidecar_file" && return
	test -z "$keywords" && return

	local -r OLD_IFS=$IFS
	IFS=";"
	local sed_commands=
	for to_delete in $keywords; do
		# NB TODO using just one pattern with "? before and after '"$to_delete"' does not work, first quote is not 
		# 	removed
		#	TBD would putting the full string of to_delete incl. quotes into a group?
		if contains_spaces "$to_delete" && ! is_quoted "$to_delete"; then
			sed_commands=$sed_commands's/(Keywords=.*;?)"'"$to_delete"'";(.*)$/\1\2/;' 
		else 
			sed_commands=$sed_commands's/(Keywords=.*;?)'"$to_delete"';(.*)$/\1\2/;' 
		fi
		
	done
	IFS=$OLD_IFS

	sed -r -i -e "/\[IPTC\]/,/^$/ $sed_commands" "$sidecar_file"
}