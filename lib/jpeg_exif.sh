__get_filetype() {
    local -r photofile=$1
	echo ${photofile##*.} | tr '[:upper:]' '[:lower:]'
}

lookup_camera_from_exif() {
	local -r photofile=$1
	local -r file_type=$(__get_filetype "$photofile")

	case $file_type in 
		raw )
			exiv2 pr -Pt -g "Exif.PanasonicRaw.Model" "$photofile" 2> /dev/null;;
		*) 
			local camera=$(exiv2 pr -Pt -g 'Exif.Image.Model' "$photofile" 2> /dev/null)
			echo "${camera//[[:space:]]/}";;
	esac
}

lookup_lens_from_exif() {
	local -r photofile=$1
	local -r file_type=$(__get_filetype "$photofile")

	case $file_type in 
		raw|crw|cr2 )
			;; # do nothing, the only cameras we have with these types are compact cameras
		orf)
			exiv2 pr -Pt -g "Exif.OlympusEq.LensModel" "$photofile" 2> /dev/null;;
		jpg )
			exiv2 pr -Pt -g  "Exif.Photo.LensModel" "$photofile" 2> /dev/null;;
		*) 
			echo "[WARN] Unknown filetype $file_type of $photofile, cannot lookup lens info" >&2;;
	esac
}

lookup_manufacturer_from_exif() {
	local -r photofile=$1
	local -r file_type=$(__get_filetype "$photofile")

	case $file_type in 
		raw )
			exiv2 pr -Pt -g "Exif.PanasonicRaw.Make" "$photofile" 2> /dev/null | xargs;;
		*) 
			exiv2 pr -Pt -g "Exif.Image.Make" "$photofile" 2> /dev/null | xargs;;
	esac
}