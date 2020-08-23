#! /usr/bin/env bash

test -v MEMORIZED_FORM_VALUES_FILE \
    || declare -r MEMORIZED_FORM_VALUES_FILE=$(readlink -m "$HOME/.local/share/photo-scripts/memorized-form-values")
if ! [[ -e "$(dirname "$MEMORIZED_FORM_VALUES_FILE")" ]]; then
    mkdir --parents "$(dirname "$MEMORIZED_FORM_VALUES_FILE")"
elif ! [[ -e "$MEMORIZED_FORM_VALUES_FILE" ]]; then
    touch MEMORIZED_FORM_VALUES_FILE
fi


############################################################################################
# Preparing form values (remembering)
############################################################################################

__lookup_memorized_value() {
    local -r fieldname=$1
    grep "^${fieldname}=" "$MEMORIZED_FORM_VALUES_FILE" | cut -d'=' -f2
}   

remember_value() (
    set -o noglob

    local -r fieldname=$1

    if [[ -e $MEMORIZED_FORM_VALUES_FILE ]]; then
        echo "$(__lookup_memorized_value "$fieldname")"
    fi
)

__purge_glob_entries_from_list() {
    local -r list=$1
    local -r old_ifs=$IFS
    IFS=!
    for entry in $list; do
        if ! [[ $entry =~ .*\*.*|.*\?.* ]]; then
            echo "$entry"
        fi
    done | paste -s -d '!' -
    IFS=$old_ifs
}

__preselect_nth_in_list() {
    local -r list=$1
    local -r index=$2
    
    local -r value_at_index=$(cut -d'!' -f $index <<<"$list")
    test -z "$value_at_index" && return

    set_preselection_in_list "$list" "$value_at_index"
}

__get_latest_added_to_list() {
    local -r list=$1    
    cut -d'!' -f 1 <<<"$list"
}

prepare_list() {
    local -r list=$1
    # modifiers is a string of modifiers (single chars), valid modifiers are "g", "b", "n", "l"
    local -r modifiers=${2:-}
    local preselected_entry=${3:-}

    local prepared_list=$list

    for (( i=0;i<${#modifiers};i++ )); do
        case ${modifiers:$i:1} in 
            # no_g_lobs
            g )
                prepared_list=$(__purge_glob_entries_from_list "$prepared_list");;
            # _b_lank option
            b )
                # ensure that there will be only one blank option by first removing all blanks
                prepared_list=$(add_blank_option_to_list "$(remove_blank_option_from_list "$prepared_list")");;
            # _n_o blank options
            n )
                prepared_list=$(remove_blank_option_from_list "$prepared_list");;
            # preselect _l_atest added    
            l ) 
                preselected_entry=$(__get_latest_added_to_list "$list")
        esac
    done

    if [[ -n $preselected_entry ]]; then
        set_preselection_in_list "$prepared_list" "$preselected_entry"
    else
        preselect_latest_in_list "$prepared_list"
    fi
}

remember_list() {
    local -r fieldname=$1
    local -r modifiers=${2:-}
    local -r preselected_entry=${3:-}

    local list="$(remember_value "$fieldname")"
    
    prepare_list "$list" "$modifiers" "$preselected_entry"
}

remember_list_for_finding() {
    local -r fieldname=$1
    remember_value "$fieldname"
}

remember_list_for_editing() (
    set -o noglob

    local -r fieldname=$1
    __purge_glob_entries_from_list "$(remember_value "$fieldname")"
)

preselect_latest_in_list() {
    local -r list=$1
    if [[ -n $list ]]; then
        echo "^$list"
    fi
}

add_blank_option_to_list() {
    local -r list=$1
    if [[ -n $list ]]; then
        echo "!$list"
    fi
}

remove_blank_option_from_list() {
    local -r list=$1
    local -r old_ifs=$IFS
    IFS=!
    for entry in $list; do
        if [[ -n $entry ]]; then
            echo "$entry"
        fi
    done | paste -s -d '!' -
    IFS=$old_ifs
}

set_blank_preselection_in_list() {
    local -r list=$1
    # TODO check if there is already a blank entry in the list and preselect that one
    echo "^!$list"
}

set_preselection_in_list() {
    local -r list=$1
    local -r value=$2
    sed 's/\('"$value"'\)/^\1/' <<<$list
}

############################################################################################
# Memorizing form values
############################################################################################

__count_char_in_string() {
    local -r c=$1
    local -r string=$2

    c_only=${string//[^$c]}
    echo ${#c_only}
}

__filter_combobox_entries_exclude_value() (

    # if we didn't use noglob here, we'd be having fun if $list has the value of "*"
    set -o noglob

    read -r list
    local -r value=$1

    IFS='!'

    for entry in $list; do
        if [[ $entry != "$value" ]]; then
            echo "$entry"
        fi
    done | paste -s -d '!' -
)

memorize_form_combobox_values() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r selected_entry=$(trim_whitespace "$3")
    local -r max_saved=${4-10}
    
    if grep -q "$fieldname=" "$saved_values_file"; then

        # get the saved values with any occurrence of $selected_entry already removed
        local -r saved_values=$(grep "$fieldname" "$saved_values_file" | cut -d'=' -f2 |\
            __filter_combobox_entries_exclude_value "$selected_entry")
        if [[ -z $saved_values ]]; then
            sed -i -e 's/^'"$fieldname"'=.*/'"$fieldname"'='"$selected_entry"'/' "$saved_values_file"
        else
            # values_count would be the new size of the list after adding the current value
            local -r values_count=$(( $(__count_char_in_string '!' "$saved_values") + 1 ))
            if (( $values_count < $max_saved )); then
                sed -i -e 's/^'"$fieldname"'=.*/'"$fieldname"'='"$selected_entry"'!'"$saved_values"'/' "$saved_values_file"
            else 
                local -r saved_values_without_last=$(echo ${saved_values%!*})
                sed -i -e 's/^'"$fieldname"'=.*/'"$fieldname"'='"$selected_entry"'!'"$saved_values_without_last"'/' "$saved_values_file"
            fi
        fi

    else
        echo "$fieldname=$selected_entry" >> "$saved_values_file"
    fi
}

memorize_form_value() {
    local -r saved_values_file=$1
    local -r fieldname=$2
    local -r value=$(trim_whitespace "$3")

    if grep -q "$fieldname=" "$saved_values_file"; then
        sed -i -e 's/^'"$fieldname"'=.*/'"$fieldname"'='"$value"'/' "$saved_values_file"
    else
        echo "$fieldname=$value" >> "$saved_values_file"
    fi    
}

############################################################################################
# Form value accessors
############################################################################################

get_option_at_index() {
    local -r options=$1
    local -r index=$2
    cut -d'|' -f "$index" <<<"$options"
}

is_option_selected() {
    set -x
    local -r options=$1
    local -r index=$2

    local -r value_at_index=$(get_option_at_index "$options" "$index")
    test "TRUE" = "$value_at_index"
}

############################################################################################
# Special form values
############################################################################################

declare -r MONTHS="January!February!March!April!May!June!July!August!September!October!November!December"

month_value_from_name() {
    local -r name=${1+$1}
    case $name in 
        Jan* )
            echo "1";;
        Feb* )
            echo "2";;
        Mar* )
            echo "3";;
        Apr* )
            echo "4";;
        May )
            echo "5";;
        Jun* )
            echo "6";;
        Jul* )
            echo "7";;
        Aug* )
            echo "8";;
        Sep* )
            echo "9";;
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