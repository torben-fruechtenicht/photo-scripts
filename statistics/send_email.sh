#! /usr/bin/env bash

set -e

# set LANG because cron will not have a suitable value for LANG
export LANG=en_US.UTF-8

declare -r MAIL_RECIPIENT=$1
if [[ -z $MAIL_RECIPIENT ]]; then
	echo "[ERROR] No mail recipient" >&2
	exit 1
fi

declare -r SUBJECT=$2
if [[ -z $SUBJECT ]]; then
	echo "[ERROR] No subject" >&2
	exit 1
fi

declare -r MAIL_BODY=$(readlink -e "$3")

set -u

if [[ -n $MAIL_BODY ]]; then
	if ! [[ -e $MAIL_BODY ]]; then
		echo "[ERROR] mail body file $MAIL_BODY does not exist" >&2
		exit 1
	fi
	cat "$MAIL_BODY" | mail -a 'MIME-Version: 1.0' -a 'Content-Type: text/text; charset=utf-8' -s "$SUBJECT" "$MAIL_RECIPIENT"
else 
	cat - | mail -a 'MIME-Version: 1.0' -a 'Content-Type: text/text; charset=utf-8' -s "$SUBJECT" "$MAIL_RECIPIENT"
fi
