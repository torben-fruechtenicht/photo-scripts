function echo_item_added_targetpath() {
    local import_item=$1
    local targetpath_part=$2

    if [[ $targetpath_part =~ ^/.+ ]]; then
        targetpath_part=${targetpath_part:1}
    fi

    if ! [[ $import_item =~ \|{1} ]]; then
        echo "$import_item|$targetpath_part"      
    else
        echo "$import_item/$targetpath_part"      
    fi
}

function source_from_import_item() {
    local -r import_item=$1
    cut -d'|' -f1 <<<"$import_item"
}

function target_from_import_item() {
    local -r import_item=$1
    cut -d'|' -f2 <<<"$import_item"
}

