# Photoid:
# - Full filename without all extensions
# - Format: <TITLE>_<YYYYMMDD>_<HHMM>_<CAMERA_ID>_<PHOTO_NUMBER>
# <PHOTONUMBER> can exist in two variants:
#   - a single alphanumerical string
#   - a single alphanumerical string (the number assigned by 
#     the camera) and a variant number (alphanumerical), separated
#     by a "-"
# <TITLE> must not contain any underscores.

function photoid_get_from_file() {
    local -r filename=$(basename "$1")
    echo "${filename%%.*}"
}

function photoid_create() {
    local title=$(tr ' ' '-' <<<"$1")
    local date=$2
    local time=$3
    local cameraid=$4
    local fullnumber=$5
    echo "$title_$date_$time_$cameraid_$fullnumber"
}

function photoid_get_cameraid() {
    cut -d'_' -f4 <<<"$1"
}

function photoid_get_title() {
    cut -d'_' -f1 <<<"$1"
}

# $1 photoid
# $2 new title
function photoid_set_title() {
    echo "${2}_$(cut -d'_' -f2- <<<$1)"
}

# fullnumber is including any variant info
function photoid_get_fullnumber() {
    cut -d'_' -f5 <<<"$1"
}