declare -r MAX_PREVIOUS=365

create_stats_file_if_missing() {
    
    local -r stats_file=$1

    if ! [[ -e $stats_file ]]; then
        echo "[INFO] Creating $stats_file" >&2
        touch "$stats_file"
        cat << EOF > "$stats_file"
current_incoming=
current_archive=

last_rotate=

$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_incoming_$i="; done)

$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_archive_$i="; done)
EOF
    fi
} 

current_count() {
    local -r source_type=$1
    local -r stats_file=$2
    value_from_stats_file $source_type "$stats_file" "0"
}

previous_count() {
    local -r source_type=$1
    local -r index=$2
    local -r stats_file=$3
    value_from_stats_file "previous_${source_type}_$index" "$stats_file" "-"
}

value_from_stats_file() {
    local -r key=$1
    local -r stats_file=$2
    local -r no_value_placeholder=$3
    local -r value=$(grep "$key=" "$stats_file" | cut -d '=' -f 2)
    if [[ -n $value ]]; then
        echo $value
    else
        echo ${no_value_placeholder--}
    fi
}
