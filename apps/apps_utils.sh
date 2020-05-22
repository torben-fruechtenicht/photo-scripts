#! /usr/bin/env bash

remove_searchdir_from_photos_list()  {
    local -r list=$1
    local -r search_dir=$2

    echo "$list" | while read -r photo; do 
        echo ${photo#$search_dir/}
    done
}