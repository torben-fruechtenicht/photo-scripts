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

# $1 - a string
# $2 - max length of string
function __truncate_to() {
    echo ${1:0:$2}
}

# $1 - title
# $2 - date taken in ISO format (yyyy:mm:dd hh:mm)
# $3 - camera
# $4 - photo number
function photoid_create() {    
    local date_iso=${2% *}
    local time_iso=${2#* }
    echo "${1// /-}_${date_iso//:/}_$(__truncate_to "${time_iso//:/}" 4)_${3}_${4}"
}

# $1 The camera name (make) from exif (normally, the "Exif.Image.Make" tag)
function photoid_camera_from_exif() {
    case "$1" in 
        DMC-FZ50 ) echo "fz50";;
        CanonPowerShotG9 ) echo "g9";;
        CanonPowerShotS70 ) echo "s70";;
        E-M10 ) echo "e-m10";;
        DSC-RX100M3 ) echo "rx100m3";;
        SM-G973F ) echo "s10";;
        NIKOND80 ) echo "d80";;
        SM-G973F ) echo "s10";;
        * )
            echo "Unknown camera $1" >&2
            exit 1;;
    esac
}

function photoid_get_cameraid() {
    cut -d'_' -f4 <<<"$1"
}

function photoid_get_title() {
    cut -d'_' -f1 <<<"$1"
}

# $1 photoid (photo filename also accepted)
# $2 new title
function photoid_set_title() {
    echo "${2}_$(cut -d'_' -f2- <<<$1)"
}

# fullnumber is including any variant info
function photoid_get_fullnumber() {
    cut -d'_' -f5 <<<"$1"
}