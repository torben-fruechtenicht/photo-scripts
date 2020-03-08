declare -r MAX_PREVIOUS=365

create_stats_file_if_missing() {
    
    local -r statsfile=$1

    if ! [[ -e $statsfile ]]; then
        echo "[INFO] Creating $statsfile" >&2
        touch "$statsfile"
        cat << EOF > "$statsfile"
current_incoming=
current_archive=
last_rotate=
$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_incoming_$i="; done)
$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_archive_$i="; done)
EOF
    fi
} 

current_count() {
    local -r sourcetype=$1
    local -r statsfile=$2
    read_statsfile_entry $sourcetype "$statsfile" "0"
}

previous_count() {
    local -r sourcetype=$1
    local -r index=$2
    local -r statsfile=$3
    local -r no_value_placeholder=${4--}
    read_statsfile_entry "previous_${sourcetype}_$index" "$statsfile" "$no_value_placeholder"
}

read_statsfile_entry() {
    local -r key=$1
    local -r statsfile=$2
    local -r no_value_placeholder=${3-0}
    local -r value=$(grep "$key=" "$statsfile" | cut -d '=' -f 2)
    if [[ -n $value ]]; then
        echo $value
    else
        echo $no_value_placeholder
    fi
}

write_statsfile_entry() {
    local -r key=$1
    local -r newvalue=$2
    local -r file=$3
    local -r line=${4-}

    # echo "[INFO] writing $file $lineno $key=$newvalue" >&2
    if [[ -z $line ]]; then
        sed -i 's/'"$key"'=.*$/'"$key"'='"$newvalue"'/' "$file"   
    else 
        sed -i "$line"' s/.*/'"$key"'='"$newvalue"'/' "$file"
    fi    
}

sed_cmd_write_statsfile_entry() {
    local -r key=$1
    local -r newvalue=$2
    local -r line=${4-}

    # echo "[INFO] writing $file $lineno $key=$newvalue" >&2
    if [[ -z $line ]]; then
        echo 's/'"$key"'=.*$/'"$key"'='"$newvalue"'/'
    else 
        echo "$line"' s/.*/'"$key"'='"$newvalue"'/'
    fi    
}



