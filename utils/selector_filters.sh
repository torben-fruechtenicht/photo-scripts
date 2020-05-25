#! /usr/bin/env bash

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
    if [[ -z $dayofmonth ]]; then
        echo "??"
    else 
        echo "$dayofmonth"
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

month_glob_from_shortname() {
    local -r monthname=${1+$1}
    case $monthname in 
        Jan )
            echo "01";;
        Feb )
            echo "02";;
        Mar )
            echo "03";;
        Apr )
            echo "04";;
        May )
            echo "05";;
        Jun )
            echo "06";;
        Jul )
            echo "07";;
        Aug )
            echo "08";;
        Seo )
            echo "09";;
        Oct )
            echo "10";;
        Nov )
            echo "11";;
        Dec )
            echo "12";;    
        * )
            echo "??";;       
    esac
}

date_path_glob() {
    local -r year=${1+$1}
    local -r month=$(month_glob_from_shortname "${2+$2}")
    local -r dayofmonth=${3+$3}
    echo "$(year_glob $year)-$month-$(dayofmonth_glob $dayofmonth)"
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
    local -r title=${1+$1}
    local -r year=${2+$2}
    local -r month=${3+$3}
    local -r dayofmonth=${4+$4}
    local -r timeofday=${5+$5}
    local -r camera="*"
    local -r photonumber_tail=${6+$6}
    echo "$(title_glob "$title")_$(date_filename_glob $year $month $dayofmonth)_$(timeofday_glob "$timeofday")_*_$(photonumber_glob "$photonumber_tail")"
}