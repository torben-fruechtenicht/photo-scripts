#! /usr/bin/env bash

set -eu
shopt -s nocasematch

declare -r FILE=$(readlink -e "$1")

[[ -f $FILE ]] && \
    [[ $FILE =~ .+\.(ORF|RAW|JPG|CRW|CR2)$ ]] && \
    ! [[ $FILE =~ .+/converted/^/+$ ]]