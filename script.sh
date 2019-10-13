#!/bin/bash

function print_help () {
	echo "Usage: $0 [-h] -i prefix -r -f regex"
}

function replace_include () {
	for file in $@
	do
		sed -i -e "s|\([[:space:]]*#[[:space:]]*include[[:space:]]*<\)\(.*>\)|\1$PREFIX\2|g" -e"s|\([[:space:]]*#[[:space:]]*include[[:space:]]*\"\)\(.*\"\)|\1$PREFIX\2|g" $file
	done
}

function replace_camel () {
	for file in $@
	do
		while true
		do
			name=$(grep -m 1 -Eo '\b[[:lower:][:digit:]]+(_[[:lower:][:digit:]]+)*[[:space:]]*\(' "$file")
			[ -z "$name" ] && break
			subst=$(echo "$name" | sed -r 's/(^|_)([a-z0-9])/\U\2/g')
			eval "sed -i 's/$name/$subst/g' \"$file\""
		done
	done
}


while getopts "h?i:rf:" opt
do
	case "$opt" in
	h)
		print_help
		exit 0
		;;
	i)
		PREFIX=$(echo "$OPTARG" | sed 's|\\|\\\\|g')
		;;
	r)
		CAMEL=true
		;;
	f)
		REGEX=$OPTARG
		;;
	*)
		print_help
		exit 0
		;;
	esac
done

shift $((OPTIND-1))

if [ -z "$1" ]
then
	TMP=$(mktemp)
	cat /dev/stdin > $TMP
	FILES="$TMP"
else
	FILES="$@"
fi

[ ! -z "$PREFIX" ] && replace_include "$FILES"
[ ! -z "$CAMEL" ] && replace_camel "$FILES"

[ ! -z "$TMP" ] && cat $TMP

exit 0
