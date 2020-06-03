#! /usr/bin/env bash

# TODO redirect hash output to devnull?
if ! $(hash notify-send); then
    echo "Cannot execute, notify-send is not installed" >&2
    exit 1
fi

declare -r NOTIFICATION_ICONS_DIR=/usr/share/icons/gnome/48x48/status
declare -r NOTIFICATION_INFO_ICON=$NOTIFICATION_ICONS_DIR/dialog-information.png
declare -r NOTIFICATION_WARN_ICON=$NOTIFICATION_ICONS_DIR/dialog-warning.png
declare -r NOTIFICATION_ERROR_ICON=$NOTIFICATION_ICONS_DIR/dialog-error.png


__notify() {
    local -r title=$1
    local -r text=$2
    local -r timeout=$4
    local -r icon=$3
    
    notify-send  -t "$timeout" -i "$icon" "$title" "$text"
}

notify_info() {
    local -r title=${1-Info}
    local -r text=${2-Done}

    __notify "$title" "$text" "$NOTIFICATION_INFO_ICON" 30000
}

notify_warning() {
    local -r title=${1-Warning}
    local -r text=${2-Something happened but the program continued}

    __notify "$title" "$text" "$NOTIFICATION_WARN_ICON" 40000
}

notify_error() {
    local -r title=${1-Error}
    local -r text=${2-There was an error}

    __notify "$title" "$text" "$NOTIFICATION_ERROR_ICON" 60000
}