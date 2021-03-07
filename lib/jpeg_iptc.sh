if ! command -v exiv2 >/dev/null 2>&1; then
	echo "[ERROR] exiv2 is not installed but required" >&2
	exit 1
fi


jpeg_set_iptc() {
	local -r jpg_file=$1
    local -r key=$2
    local -r value=$3
	
	if [[ $key == "Keywords" ]]; then
		echo "[ERROR] Keywords must be added with jpeg_add_iptc_keywords" >&2
		return 1
	fi

	exiv2 -M"set Iptc.Application2.$key String $value" "$jpg_file" 2> /dev/null
}

jpeg_get_iptc() {
	local -r jpg_file=$1
	local -r key=$2

	exiv2 -PIt -K "Iptc.Application2.$key" "$jpg_file" 2> /dev/null
}

jpeg_add_iptc_keywords() {
	local -r jpg_file=$1
    local -r keywords=$2

	local -r old_keywords=$(jpeg_get_iptc "$jpg_file" "Keywords")

	local -r OLD_IFS=$IFS
	IFS=";"

	for new_keyword in $keywords; do
		if [[ "$old_keywords" =~ .*$new_keyword.* ]]; then
			continue
		fi

		exiv2 "-Madd Iptc.Application2.Keywords String '$(quote "$new_keyword")'" "$jpg_file" 2> /dev/null
	done

	IFS=$OLD_IFS
}

jpeg_remove_iptc_keywords() {
	local -r jpg_file=$1
	# $2 is a comma-separated list of keywords, no quotes needed (are removed anyway)
    local -r keywords=$(tr --delete '"' <<<"$2")

	local -r old_keywords=$(jpeg_get_iptc "$jpg_file" "Keywords" | tr '\n' ';')

	# removes *all* keywords, meaning we have to re-add all which should not be removed
	exiv2 -M'del Iptc.Application2.Keywords' "$jpg_file" 2> /dev/null
	
	OLD_IFS=$IFS
	IFS=";"
	for old_keyword in $old_keywords; do
		if [[ "$keywords" =~ (.*;)*$(unquote "$old_keyword")(;.*)*  ]]; then 
			continue
		else
			exiv2 "-Madd Iptc.Application2.Keywords String '$(quote "$old_keyword")'" "$jpg_file" 2> /dev/null
		fi
	done
	IFS=$OLD_IFS
}