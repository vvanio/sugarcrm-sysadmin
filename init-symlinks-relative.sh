#!/usr/bin/env bash

do_symlink() # source destination host(s)
{
	# If symlink doesn't exist
	if test ! -L "$1"
	then
		if test ! -e "$2/$1"
		then
			echo "File/folder: $2/$1 doesn't exist"
			exit -1
		else
			dir=`dirname $1`
			if test ! -d $dir
			then
				mkdir -p "$dir"
				echo "Folder: $dir created"
			fi
			# Create the symlink with a relative path
			ln -s "`echo $dir | sed -e s/[a-zA-Z\_-]*/../g`/$2/$1" "$1"
			echo "$1 -> $2/$1"
		fi
	fi
}

### Main

# Read file from first arg
if test -n "$1"; then
	F=$1
else
	echo "Usage: $0 [-|file]"
	exit -1
fi

# Read all lines
while read line; do
	# ignore blanks and comments
	if test -n "$line" -a "${line:0:1}" != "#"; then
		do_symlink $line `dirname $1`
	fi
done < $F