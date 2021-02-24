function echo_item_added_targetpath() {
    local import_item=$1
    local targetpath_part=$2

    if [[ $targetpath_part =~ ^/.+ ]]; then
        targetpath_part=${targetpath_part:1}
    fi

    if [[ $import_item =~ .+\|$ ]]; then
        echo "$import_item$targetpath_part"      
    else
        echo "$import_item/$targetpath_part"      
    fi
}

