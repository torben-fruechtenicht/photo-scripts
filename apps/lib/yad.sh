#! /usr/bin/env bash

run_yad() {
    local -r title=$1
    # "\r" adds a linebreak (text in yad is rendered with pango) - but only if we use "echo -e
    local -r text="$2\r"
    shift 2

    local -r yad_options="--borders=10 --fixed --center"
    yad $yad_options --title="$title" --text="$(echo -e "$text")" "$@"
}

run_yad_selector_result_action_dialog() {
    local -r title=$1
    local -r selected_photos=$2
    local -r search_dir=$3
    local -r action_text=$4
    shift 4

    local -r selected_photos_count=$(echo "$selected_photos" | wc -l)
    local -r selected_photos_list=$(__render_selected_photos_list \
        "$(__remove_searchdir_from_photos_list "$selected_photos" "$search_dir")")
    # "\r" adds a linebreak (text in yad is rendered with pango) - but only if we use "echo -e
    local -r text="$(echo -e "Selected $selected_photos_count photo(s) from $search_dir:\r\r$selected_photos_list\r$action_text")"

    run_yad "$title" "$text" "$@"
}

__remove_searchdir_from_photos_list() {
    local -r list=$1
    local -r search_dir=$2

    echo "$list" | while read -r photo; do 
        echo ${photo#$search_dir/}
    done
}

__render_selected_photos_list() {
    local -r photos=$1
    # TODO if more than N in list, cut list after N entries (and maybe add a button to repeat the search)
    # TODO spreach across 2 columns if more than M entries in list
    #       https://unix.stackexchange.com/a/59292
    echo "$photos"
}
