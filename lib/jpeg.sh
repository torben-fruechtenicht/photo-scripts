if ! command -v exiv2 >/dev/null 2>&1; then
	echo "[ERROR] exiv2 is not installed but required" >&2
	exit 1
fi


jpeg_set_iptc() {
    local -r key=$1
    local -r value=$2
	local -r jpg_file=$3

	if [[ $key == "Keywords" ]]; then
		echo "[ERROR] Keywords must be done with jpeg_set_iptc_keywords" >&2
		return 1
	fi

	exiv2 -M"set Iptc.Application2.$key String $value" "$jpg_file" 2> /dev/null
	echo "[INFO] set  Iptc.Application2.$key $value" >&2
}

jpeg_get_iptc() {
	local -r key=$1
	local -r jpg_file=$2

	exiv2 -PIt -K "Iptc.Application2.$key" "$jpg_file" 2> /dev/null
}

# jpeg_set_exif() {

# }

# exiv_get_exif_key() {
#     local -r jpg_file=$1
#     local -r exif_key=$2
#     # exiv2 is always printing this annoying but harmless error about date format, try to suppress only that one
#     # but print others
#     exiv2 pr -Pt -g "Exif.$exif_key" "$jpg_file" 2>1 | grep -v "Warning: Unsupported date format"
# }

# exiv_get_iptc_key() {
#     local -r jpg_file=$1
# }

jpeg_set_iptc_keywords() {
    local -r keywords=$1
    local -r jpg_file=$2

	local -r old_keywords=$(jpeg_get_iptc "Keywords" "$jpg_file")

	local -r OLD_IFS=$IFS
	IFS=";"

	for new_keyword in $keywords; do
		if [[ "$old_keywords" =~ .*$new_keyword.* ]]; then
			continue
		fi
		# set -x
		if [[ $new_keyword =~ .+[[:space:]].+ ]]; then
			needs_keywords=
		else 
			unset needs_keywords
		fi

		# FIXME use add (only add? or set for first?) for setting keywords
		# for quoting, use "-Madd Iptc.Application2.Keywords String '\"a b\"'"
		exiv2 "-Madd Iptc.Application2.Keywords String '${needs_keywords+\"}$new_keyword${needs_keywords+\"}'" "$jpg_file" 2> /dev/null

		# set +x
	done

	IFS=$OLD_IFS
}