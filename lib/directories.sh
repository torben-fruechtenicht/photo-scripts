# All paths passed to functions must be at least relative to the collection root. Absolute paths are even better.

# "leaf" is the directory where the original photo files are located. There can be directories below (like "converted")
# but that is no longer part of the collection directory layout. Therefore, it is the starting point if we need
# to locate specific collection directories in the hierarchy above.
__directories_locate_collection_leaf_path() {
    local direct_parent=${1%/*}
    if [[ $direct_parent =~ ".*/converted" ]]; then 
        echo ${direct_parent%/*}
    else
        echo "$direct_parent"
    fi
}

directories_lookup_album_from_file() {
    local leaf_path=$(__directories_locate_collection_leaf_path "$1")
    local album_path=${leaf_path%/????-??-??}
    echo "${album_path##*/}"
}

directories_collect_albums_from_files() {
    for file in $@; do 
        echo $(directories_lookup_album_from_file "$file")
    done | sort -u | paste -s -d ";"
}

# $1 - a date in ISO format (yyyy:mm:dd)
# $2 - album name
directories_create_photofile_path_from_isodate_album() {
    # FIXME replace spaces in $2
    echo "${1%%:*}/$2/${1//:/-}"
}