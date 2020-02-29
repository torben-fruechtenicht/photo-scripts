declare -r MAX_PREVIOUS=365

create_stats_file_if_missing() {
    
    local -r stats_file=$1

    if ! [[ -e $stats_file ]]; then
        echo "[INFO] Creating $stats_file" >&2
        touch "$stats_file"
        cat << EOF > "$stats_file"
current_incoming=
current_archive=

last_rotate_incoming=
$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_incoming_$i="; done)

last_rotate_archive=
$(for (( i=1; i<= $MAX_PREVIOUS; i++ )); do echo "previous_archive_$i="; done)
EOF
    fi
} 
