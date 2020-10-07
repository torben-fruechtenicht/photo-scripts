# Functions for producing the values to put into IPTC

iptc_headline_from_photofile() {
    local -r photo_filename=$(basename "$1")
    local -r fullname=${photo_filename%%.*}
    # FIXME use own pattern from pattern vars, only group the required parts. 
    # FIXME all pattern vars should not include groupings (unless for quantifiers)
    sed -r 's/'"$PHOTO_FULLNAME_PATTERN"'/\1 \5/' <<<"$fullname"
}

iptc_caption_from_photofile() {
    local -r photo_filename=$(basename "$1")
    local -r fullname=${photo_filename%%.*}

    # TBD to add also extra text so that caption will be at least one line of caption text and the 
    #   fullname line, we need to find out how to handle newlines. for jpeg, including a "\n" works fine
    #   (incl. Flickr) but it does not work with pp3 files: caption property becomes multiple lines in 
    #   the pp3 file, the newline went missing. (In addition to that, the previous fullname also ends up
    #   in the file, maybe faulty pattern.) So RawTherapee will only have the first line.

    # TBD TODO how to handle cases where caption changes because a photo title was changed but there is
    #   some extra caption text (added before)?
    # TBD similar case: same but there is also some extra caption text given when updating caption with 
    #   existing text?

    echo "[$fullname]"
}

iptc_caption_from() {
    local -r photo_filename=$(basename "$1")
    local -r description=$2
    local -r photoid=${photo_filename%%.*}

    # we need the linebreaks as literals here because that's the way we have to write them
    # into sidecar files. in jpeg files, there are real linebreaks. which makes it more
    # complex when we have to extract the description part out of the caption value: we need
    # 2 functions for jpeg and sidecar files.
    echo "${description:+$description\n\n}[$photoid]"
}