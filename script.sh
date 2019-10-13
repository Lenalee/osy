#!/bin/bash -ae

PREFIX=
REGEX=

function print_help () {
	echo "Usage: $0 [-h] -i prefix -r -f regex"
}

function do_replace () {
	sed "s|\([[:space:]]*#[[:space:]]*include[[:space:]]*<\)\(.*>\)|\1$PREFIX\2|g" | sed "s|\([[:space:]]*#[[:space:]]*include[[:space:]]*\"\)\(.*\"\)|\1$PREFIX\2|g" 
}

function do_camel () { 
	sed -r -e ':loop
/^[[:lower:][:digit:]]+[[:lower:][:digit:]_]+\(/{s/(^|_)([a-z0-9])/\U\2/g
b loop}'
}

function replace_include () {
	[ -z "$1" ] && (do_replace; exit 0)

	for file in $@
	do
		TMP=$(mktemp)
		cat $file | do_replace > $TMP
		mv $TMP $file
	done
}

function replace_camel () {
	[ -z "$1" ] && (do_camel; exit 0)

	for file in $@
	do
		TMP=$(mktemp)
		cat $file | do_camel > $TMP
		mv $TMP $file
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
[ ! -z "$PREFIX" ] && replace_include "$@"
[ ! -z "$CAMEL" ] && replace_camel "$@"

exit 0
