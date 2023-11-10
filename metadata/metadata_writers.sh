# Functions for writing metadata (IPTC, EXIF) into files (if they support it). 
# Applies fixed formats for select metadata properties.

function write_jpg_iptc() {
    local -r jpgfile=$1
    local -r iptckey=$2
    local -r value=$3

    jpeg_set_iptc "$jpgfile" "$iptckey" "$value"
}

function write_rawtherapee_sidecar_iptc() {
    local -r sidecarfile=$1
    local -r iptckey=$2
    local -r value=$3

    # RawTherapee sidecar files use different names for some iptc properties, translate where needed
    local rt_iptckey=$iptckey
    case $iptckey in 
        Byline ) rt_iptckey=Creator;;
    esac
}

function write_iptc() {
    local -r file=$1
    local -r extension=${file##*.}
    local -r iptckey=$2
    local -r value=$3

    case $extension in
        jpg|JPG )
            write_jpg_iptc $file $iptckey "$value";; 
        pp3|PP3 )
            write_rawtherapee_sidecar_iptc $file $iptckey "$value";; 
        * )
            echo "[WARN] No IPTC writer for filetype $extension" >&2;;
    esac
}

function set_iptc_headline_from_filename() {
    local file=$1

    local filename=${file##*/}
    local basename=${filename%%.*}

    local title=${basename%%_*}
    local photonumber=${basename##*_}
    local headline="$title $photonumber"
    write_iptc "$file" "Headline" "$headline"
}

function set_iptc_caption_from_filename() {
    local filename=${1##*/}
    write_iptc "$1" "Caption" "[${filename%%.*}]"
}

function set_iptc_byline() {
    write_iptc "$1" "Byline" "$2"
}

function __get_datetaken_year_from_filename() {
    local photofile=$1

    local photobasename=${photofile##*/}
    photobasename=${photobasename%.*}

    local strippedoftitle=${photobasename#*_}
    local datetaken=${strippedoftitle%%_*}
    local yearlength=$(( ${#datetaken} - 4 ))
    echo ${datetaken:0:yearlength}
}

function set_iptc_copyright_notice() {
    local -r file=$1
    local -r photographer=$2
    
    local -r year=$(__get_datetaken_year_from_filename "$file")
    local -r notice="Copyright (c) $photographer $year"
    write_iptc $file "Copyright" "$notice"
}

function set_album_iptc_keyword_from_path() {
    local -r file=$1
    add_iptc_keyword "$file" "$(albumname_from_file "$file")"
}

function set_title_iptc_keyword_from_filenane() {
    local -r file=$1
    local filename=${file##*/}
    local basename=${filename%%.*}
    add_iptc_keyword "$file" "${basename%%_*}"
}

function add_iptc_keyword() {
    local -r file=$1
    local -r keyword=$2

    jpeg_add_iptc_keywords "$file" "$keyword"
}