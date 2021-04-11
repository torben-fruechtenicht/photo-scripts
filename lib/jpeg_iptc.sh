if ! command -v exiv2 >/dev/null 2>&1; then
	echo "[ERROR] exiv2 is not installed but required" >&2
	exit 1
fi

# there is no way to do "test -e $glob" (where $glob expands to more than one file) 
# in the bash shell, unfortunately.
# the secure way out of this dilemma is to use compgen
# see https://stackoverflow.com/a/34195247/1295519
function glob_matches() {
    local -r glob=$1
    compgen -G "$glob" > /dev/null
}

function __safe_exiv2_call() (
	set +e
	local -r file=$1
	shift 1

	local exiv2_out exiv2_rc

	exiv2_out=$(exiv2 "$@" "$file" 2>&1)
	exiv2_rc=$?

	if [[ $exiv2_rc != 0 ]]; then
		echo "[ERROR] exiv2 $@ $file failed with return code $exiv2_rc" >&2
		# TODO only print the part from exiv2_out which is the actual error (i.e. starting with "Exiv2 exception")? because the 
		# remaining info will always be printed, even if it succeeds
		echo "$exiv2_out" | egrep -v "Error:|Warning:" >&2 || true 
		# failed calls to exiv2 might leave tmp files lying around, delete all that match the expected pattern.
		if glob_matches "$file?*"; then
			rm $file?*
		fi
	else 
		# even if the call was successful, there might have been errors. since there is no easy
		# way to already have stdout and stderr handled separately, we must work around this here
		# by greping
		# extra "|| true" added so we don't have a bad return code if there were no error string to filter out
		echo "$exiv2_out" | grep -v "Error:" || true
	fi

	# TBD next call probably not needed
	set -e
)


jpeg_set_iptc() {
	local -r jpg_file=$1
    local -r key=$2
    local -r value=$3
	
	if [[ $key == "Keywords" ]]; then
		echo "[ERROR] Keywords must be added with jpeg_add_iptc_keywords" >&2
		return 1
	fi

	__safe_exiv2_call "$jpg_file" -M "set Iptc.Application2.$key String $value"
}

jpeg_get_iptc() {
	local -r jpg_file=$1
	local -r key=$2
	__safe_exiv2_call "$jpg_file" -PIt -K "Iptc.Application2.$key"
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

		__safe_exiv2_call "$jpg_file" -M "add Iptc.Application2.Keywords String '$(quote "$new_keyword")'"
	done

	IFS=$OLD_IFS
}

jpeg_remove_iptc_keywords() {
	local -r jpg_file=$1
	# $2 is a comma-separated list of keywords, no quotes needed (are removed anyway)
    local -r keywords=$(tr --delete '"' <<<"$2")

	local -r old_keywords=$(jpeg_get_iptc "$jpg_file" "Keywords" | tr '\n' ';')

	# del removes *all* keywords, meaning we have to re-add all which should not be removed
	__safe_exiv2_call "$jpg_file" -M "del Iptc.Application2.Keywords"
	
	OLD_IFS=$IFS
	IFS=";"
	for old_keyword in $old_keywords; do
		if [[ "$keywords" =~ (.*;)*$(unquote "$old_keyword")(;.*)*  ]]; then 
			continue
		else
			__safe_exiv2_call "$jpg_file" -M "add Iptc.Application2.Keywords String '$(quote "$old_keyword")'"
		fi
	done
	IFS=$OLD_IFS
}