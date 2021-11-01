#! /usr/bin/env bash

function lookup_search_directory_from_option_key() {
    local -r search_dirs_file=$1
    local -r search_dir_name=$2
    grep "$search_dir_name=" "$search_dirs_file" | cut -d"=" -f2
}

function get_search_directories_as_yad_option_keys() {
    local -r search_dirs_file=$1
    cat "$search_dirs_file" | cut -d"=" -f1 | paste -s -d '!' -
}