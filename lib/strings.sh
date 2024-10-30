contains_spaces() {
	local -r string=$1
	[[ $string =~ .+[[:space:]].+ ]]
}

is_quoted() {
	local -r string=$1
	[[ $string =~ \".+\" ]]
}

quote() {
	local -r string=$1
	if contains_spaces "$string" && ! is_quoted "$string"; then
		echo "\"$string\""
	else
		echo $string
	fi	
}

unquote() {
    local string=$1
    if is_quoted "$string"; then
        string="${string%\"}"
        echo "${string#\"}"
    else    
        echo "$string"
    fi
}