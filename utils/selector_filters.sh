#! /usr/bin/env bash

year_glob() {
    local -r year=${YEAR+$YEAR}
    if [[ -z $year ]]; then
        echo "????"
    else 
        echo "$year"
    fi
}

month_glob() {
    local -r month=${MONTH+$MONTH}
    if [[ -z $month ]]; then
        echo "??"
    else 
        echo "$month"
    fi
}

dayofmonth_glob() {
    local -r dayofmonth=${DAY_OF_MONTH+$DAY_OF_MONTH}
    if [[ -z $dayofmonth ]]; then
        echo "??"
    else 
        echo "$dayofmonth"
    fi
}

album_glob() {
    local -r album=${ALBUM+$ALBUM}
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
    local -r month=$(month_glob_from_shortname "${MONTH+$MONTH}")
    echo "$(year_glob)-$month-$(dayofmonth_glob)"
}

date_filename_glob() {
    date_path_glob | tr --delete '-'
}

title_glob() {
    local -r title=${TITLE+$TITLE}
    if [[ -z $title ]]; then
        echo "*"
    else 
        echo "$title"
    fi
}

timeofday_glob() {
    local -r timeofday=${TIME_OF_DAY+$TIME_OF_DAY}
    if [[ -z $timeofday ]]; then
        echo "????"
    else 
        echo "$timeofday"
    fi
}

photonumber_glob() {
    local -r number_tail=${PHOTO_NUMBER_TAIL+$PHOTO_NUMBER_TAIL}
    if [[ -z $number_tail ]]; then
        echo "*"
    else 
        echo "*$number_tail"
    fi
}

filename_glob() {
    local -r extension_param=${1+$1}
    if [[ -z $extension_param ]]; then
        local -r extension_glob="???"
    else
        local -r extension_glob=$extension_param
    fi

    echo "$(title_glob)_$(date_filename_glob)_$(timeofday_glob)_*_$(photonumber_glob).$extension_glob"
}

extensions_regex_alternatives() {
    local -r extensions=${EXTENSIONS+$EXTENSIONS}
    if [[ -z $extensions ]]; then
        echo "???"
    else 
        echo "$extensions" | tr ' ' '|'
    fi
}