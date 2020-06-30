#! /usr/bin/env bash

declare -r MEMORIZED_FORM_VALUES_FILE=$(readlink -m "$HOME/.local/share/photo-scripts/memorized-form-values")
if ! [[ -e "$(dirname "$MEMORIZED_FORM_VALUES_FILE")" ]]; then
    mkdir --parents "$(dirname "$MEMORIZED_FORM_VALUES_FILE")"
elif ! [[ -e "$MEMORIZED_FORM_VALUES_FILE" ]]; then
    touch MEMORIZED_FORM_VALUES_FILE
fi


declare -r MONTHS="January!February!March!April!May!June!July!August!September!October!November!December"

month_value_from_name() {
    local -r name=${1+$1}
    case $name in 
        Jan* )
            echo "01";;
        Feb* )
            echo "02";;
        Mar* )
            echo "03";;
        Apr* )
            echo "04";;
        May )
            echo "05";;
        Jun* )
            echo "06";;
        Jul* )
            echo "07";;
        Aug* )
            echo "08";;
        Sep* )
            echo "09";;
        Oct* )
            echo "10";;
        Nov* )
            echo "11";;
        Dec* )
            echo "12";;    
        * )
            echo;;       
    esac
}

declare -r DAYS_OF_MONTH="01!02!03!04!05!06!07!08!09!10!11!12!13!14!15!16!17!18!19!20!21!22!23!24!25!26!27!28!29!30!31"


__lookup_memorized_value() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    grep "^${fieldname}=" "$saved_values_file" | cut -d'=' -f2
}   

get_memorized_values_or_default() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r default=$3

    if [[ -e $saved_values_file ]]; then
        echo $(__lookup_memorized_value "$saved_values_file" "$fieldname")
    else 
        echo "$default"
    fi
}

get_memorized_value_preselected_in_all_values_list() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r all_values=$3

    local values_optional_saved_preselected=$all_values

    if [[ -e $saved_values_file ]]; then
        local -r saved_value=$(__lookup_memorized_value "$saved_values_file" "$fieldname")
        if [[ -n $saved_value ]]; then
            values_optional_saved_preselected=$(echo "$all_values" | sed 's/\('"$saved_value"'\)/^\1/')
        fi
    fi

    echo "$values_optional_saved_preselected"
}

__count_char_in_string() {
    local -r c=$1
    local -r string=$2

    c_only=${string//[^$c]}
    echo ${#c_only}
}

__filter_combobox_entries_exclude_value() (
    read -r list
    local -r value=$1

    IFS='!'
    for entry in $list; do
        if [[ $entry != $value ]]; then
            echo "$entry"
        fi
    done | paste -s -d '!' -
)

memorize_form_combobox_values() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r current_value=$3
    local -r max_saved=${4-10}
    
    if grep -q "$fieldname=" "$saved_values_file"; then

        # get the saved values with any occurrence of $current_value already removed
        local -r saved_values=$(grep "$fieldname" "$saved_values_file" | cut -d'=' -f2 |\
            __filter_combobox_entries_exclude_value "$current_value")
        if [[ -z $saved_values ]]; then
            sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'/' "$saved_values_file"
        else
            # values_count would be the new size of the list after adding the current value
            local -r values_count=$(( $(__count_char_in_string '!' "$saved_values") + 1 ))
            if (( $values_count < $max_saved )); then
                sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'!'"$saved_values"'/' "$saved_values_file"
            else 
                local -r saved_values_without_last=$(echo ${saved_values%!*})
                sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$current_value"'!'"$saved_values_without_last"'/' "$saved_values_file"
            fi
        fi

    else
        echo "$fieldname=$current_value" >> "$saved_values_file"
    fi
}

memorize_form_value() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r value=$3

    if grep -q "$fieldname=" "$saved_values_file"; then
        sed -i -e 's/'"$fieldname"'=.*/'"$fieldname"'='"$value"'/' "$saved_values_file"
    else
        echo "$fieldname=$value" >> "$saved_values_file"
    fi    
}
