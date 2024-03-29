#!/bin/bash

F=0;

function print_help () {
	echo "Usage: $0"
	echo "-h help"
	echo "-i <prefix> add prefix to include name"
	echo "-r rename functions"
	echo "-f <patern> rename only functions with specific pattern"
}

function replace_include () {
	for file in "$@"
	do
		sed -i -e "s|\([[:space:]]*#[[:space:]]*include[[:space:]]*<\)\(.*>\)|\1$PREFIX\2|g" -e"s|\([[:space:]]*#[[:space:]]*include[[:space:]]*\"\)\(.*\"\)|\1$PREFIX\2|g" $file
	done
}

function replace_camel () {

	echo "$REGEX" >&2;
	for file in $@
	do
		names=$(grep -Eo '\b[[:lower:][:digit:]]+(_[[:lower:][:digit:]]+)*[[:space:]]*\(' "$file" | uniq | grep -E "$REGEX")
		for name in $names
		do
			subst=$(echo $name | sed -r 's/(_)([a-z0-9])/\U\2/g')
			if [ "$F" -eq 1 ]; then
				eval "sed -i 's/ $name/ $subst/g' \"$file\""
			else
				eval "sed -i 's/$name/$subst/g' \"$file\""
			fi
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
		PREFIX=`printf '%q' "${OPTARG}"`
		;;
	r)
		CAMEL=true
		;;
	f)	F=1;
		REGEX="${OPTARG}"
		;;
	*)
		print_help
		exit 1
		;;
	esac
done

shift $((OPTIND-1))

if [ -z "$1" ]
then
	TMP=$(mktemp)
	cat > "$TMP"
	FILES="$TMP"
else
	FILES="$@"
fi

[ -z "$REGEX" ] && REGEX=.*
[ ! -z "$PREFIX" ] && replace_include "$FILES"
[ ! -z "$CAMEL" ] && replace_camel "$FILES"
[ ! -z "$TMP" ] && cat "$TMP"

exit 0
