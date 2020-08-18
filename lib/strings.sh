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
	if ! __is_quoted "$string" && __contains_spaces "$string"; then
		echo "\"$string\""
	else
		echo $string
	fi	
}