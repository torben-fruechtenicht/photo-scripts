# Functions for producing the values to put into IPTC

# $1 - title
# $2 - number
iptc_headline_from() {
    echo "$1 $2"
}

iptc_headline_from_photofile() {
    local -r photo_filename=$(basename "$1")
    local -r fullname=${photo_filename%%.*}
    # FIXME use own pattern from pattern vars, only group the required parts. 
    # FIXME all pattern vars should not include groupings (unless for quantifiers)
    sed -r 's/'"$PHOTO_FULLNAME_PATTERN"'/\1 \5/' <<<"$fullname"
}

# $1 - photoid
# $2 - description, optional
iptc_caption_from() {
    # we need the linebreaks as literals here because that's the way we have to write them
    # into sidecar files. in jpeg files, there are real linebreaks. 
    echo "${2:+$2\n\n}[$1]"
}

# $1 - photoid
# $2 - description, optional
iptc_create_caption() {
    if [[ $# = 2 ]] && [[ -n $2 ]]; then
        local description=$2
        echo -e "$description\n\n[$1]"
    else
        echo "[$1]"
    fi
}

# $1 - photoid
# $2 - the existing caption
iptc_update_caption_photoid() {
    sed -r "s/\[$PHOTOID_PATTERN\]/[$1]/" <<<$2
}