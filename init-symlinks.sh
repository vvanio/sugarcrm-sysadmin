#!/usr/bin/env bash

# TODO: expanduser/$HOME or ...
# TODO: some comments

check_hosted() # hostnames ...
{
	case `hostname` in "$@" )
			return 0
		;;
	esac

	return 1
}

do_symlink() # source destination host(s)
{
	# host arguments and hostname in hosts?
	args=($@)
	hosts=${args[@]:2}
	check_hosted $hosts
	if test -n "$hosts" -a $? -ne 0; then return; fi;

	# if link, check target
	if test -h "$2" -a "`readlink $2`" != "$1"
	then
		rm "$2"
	fi

	if test ! -L "$2"
	then
		if test ! -e "$2"
		then
			echo "$2 -> $1"
			ln -s "$1" "$2"
		else
			echo "Not linking existing $1 $2"
		fi
	else
		if test `readlink $2` != $1; then
			echo "Cannot link $1 $2";
		fi;
	fi
}

### Main

# Read from file (first arg) or stdin
if test -z "$1"; then
	if [ "$(uname)" == "Linux" ]
	then
		F=~/.conf/symlinks.tab
	else if [ "$(uname)" == "Darwin" ]
	then
		F=~/.conf/symlinks.darwin.tab
	else
		echo "Usage: $0 [-|file]"
		exit -1
	fi;fi
else
	F=$1
fi

if test "$F" != "-"; then
	exec 6<&0 # Link fd#6 with stdin
	exec < $F # Replace stdin with arg 1 (file expected)
fi

# Read all lines
while read line; do
	# ignore blanks and comments
	if test -n "$line" -a "${line:0:1}" != "#"; then
		do_symlink $line
	fi
done

if test "$F" != "-"; then
	exec 0<&6 6<&- # restore stdin and close fd#6
fi
