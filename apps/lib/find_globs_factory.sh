#! /usr/bin/env bash

# TODO rename to "find_globs.sh" after month_glob_from_shortname has been removed

year_glob() {
    local -r year=${1+$1}
    if [[ -z $year ]]; then
        echo "????"
    else 
        echo "$year"
    fi
}

month_glob() {
    local -r month=${1+$1}
    if [[ -z $month ]]; then
        echo "??"
    else 
        echo "$month"
    fi
}

dayofmonth_glob() {
    local -r dayofmonth=${1+$1}
    if [[ $dayofmonth =~ ^[0-9]{2}$ ]] && (( 1 <= $dayofmonth )) && (( $dayofmonth <= 31  )); then
        echo "$dayofmonth"
    else 
        echo "??"
    fi
}

album_glob() {
    local -r album=${1+$1}
    if [[ -z $album ]]; then
        echo "*"
    else 
        echo "$album"
    fi
}

month_glob() {
    local -r month=${1+$1}
    if [[ -z $month ]]; then
        echo "??"
    else 
        printf "%02d" "$month"
    fi
}

date_path_glob() {
    local -r year=${1+$1}
    local -r month=${2+$2}
    local -r dayofmonth=${3+$3}
    echo "$(year_glob $year)-$(month_glob "$month")-$(dayofmonth_glob $dayofmonth)"
}

date_filename_glob() {
    local -r year=${1+$1}
    local -r month=${2+$2}
    local -r dayofmonth=${3+$3}
    date_path_glob $year $month $dayofmonth | tr --delete '-'
}

title_glob() {
    local -r title=${1+$1}
    if [[ -z $title ]]; then
        echo "*"
    else 
        echo "$title"
    fi
}

timeofday_glob() {
    local -r timeofday=${1+$1}
    if [[ -z $timeofday ]]; then
        echo "????"
    else 
        echo "$timeofday"
    fi
}

photonumber_glob() {
    local -r number_tail=${1+$1}
    if [[ -z $number_tail ]]; then
        echo "*"
    else 
        echo "*$number_tail"
    fi
}

filename_glob() {
    local -r title=$(title_glob "${1+$1}")
    local -r year=${2+$2}
    local -r month=${3+$3}
    local -r dayofmonth=${4+$4}
    local -r date=$(date_filename_glob $year $month $dayofmonth)
    local -r timeofday=$(timeofday_glob "${5+$5}")
    local -r number=$(photonumber_glob "${6+$6}")
    local -r camera="*"
    echo "${title}_${date}_${timeofday}_${camera}_${number}"
}