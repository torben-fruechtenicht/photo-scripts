lookup_camera_from_exif() {
	local -r photofile=$1
	local -r file_type=$(tr '[:upper:]' '[:lower:]' <<<${photofile##*.})

	case $file_type in 
		raw )
			exiv2 -Pt -g "Exif.PanasonicRaw.Model" "$photofile" 2> /dev/null;;
		*) 
			local camera=$(exiv2 -Pt -g 'Exif.Image.Model' "$photofile" 2> /dev/null)
			echo "${camera//[[:space:]]/}";;
	esac
}

lookup_lens_from_exif() {
	local -r photofile=$1
	local -r file_type=$(tr '[:upper:]' '[:lower:]' <<<${photofile##*.})

	case $file_type in 
		raw|crw|cr2|arw )
			;; # do nothing, the only cameras we have with these types are compact cameras
		orf)
			exiv2 -Pt -g "Exif.OlympusEq.LensModel" "$photofile" 2> /dev/null || true;;
		jpg )
			exiv2 -Pt -g  "Exif.Photo.LensModel" "$photofile" 2> /dev/null || true;;
		*) 
			echo "[WARN] Unknown filetype $file_type of $photofile, cannot lookup lens info" >&2;;
	esac
}

lookup_manufacturer_from_exif() {
	local -r photofile=$1
	local -r file_type=$(tr '[:upper:]' '[:lower:]' <<<${photofile##*.})

	case $file_type in 
		raw )
			exiv2 -Pt -g "Exif.PanasonicRaw.Make" "$photofile" 2> /dev/null | xargs;;
		*) 
			exiv2 -Pt -g "Exif.Image.Make" "$photofile" 2> /dev/null | xargs;;
	esac
}

lookup_image_width_from_exif() {
	local -r photofile=$1
	# yes, there should be a way to get the correct dimension from exif tags (instead of brute forcing
	# exiv2 default output). but I don't know how to do it. some cameras give strange numbers...
	exiv2 "$photofile" | grep "Image size" | sed -r 's/Image size\s+:\s+([0-9]+)\sx\s([0-9]+)/\1/'
}

lookup_image_height_from_exif() {
	local -r photofile=$1
	exiv2 "$photofile" | grep "Image size" | sed -r 's/Image size\s+:\s+([0-9]+)\sx\s([0-9]+)/\2/'
}

lookup_year_from_exif() {
	local -r photofile=$1
	exiv2 -Pt -g 'Exif.Photo.DateTimeOriginal' "$photofile" 2> /dev/null | cut -d':' -f 1
}

lookup_exif_datetimeorig_or_lastmod() {
	local photofile=$1

	exif_date=$(exiv2 -Pt -g 'Exif.Photo.DateTimeOriginal' "$photofile" 2> /dev/null)
	if [[ -n $exif_date ]]; then
		echo "$exif_date"
	else 
		# actually, we should use "%w" as the format string for stat but that 
		# must not be available in all cases
		date '+%Y:%m:%d %H:%M:%S' -d "$(stat --format %y "$photofile")"
	fi
}