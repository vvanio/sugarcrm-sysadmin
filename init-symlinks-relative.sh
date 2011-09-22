#!/usr/bin/env bash

#
# Initialize symlinks from .symlinks
#

do_symlink() # $v
{
	# If symlink doesn't exist
	if test ! -L "$1"
	then
		if test -e "$1"
		then
			rm -rf $1;
		fi
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

if test ! -e sugar_version.php
then
	echo "This script must be run from a sugar installation directory. ";
	exit 1
fi

# Read file from first arg
if test -n "$1"; then
	F=$1
# Read file from default location
elif test -e ".symlinks"; then
	F=.symlinks
else
	echo "Usage: $0 [file]"
	exit -1
fi

# Read all lines
# Whitespace determines 'do_symlink' arguments, paths cannot contain any spaces!
i=0
while read line; do
	i=$(expr $i + 1);
	# ignore blanks and comments
	if test -n "$line" -a "${line:0:1}" != "#"; then
		DIR=$(dirname $F)
		if test -z "$DIR"; then DIR=.; fi
		if test ! -e "$DIR/$line"; then
			echo "! Non-existant path $line, given at $F:$i"
		else
			do_symlink $line `dirname $1`
		fi
	fi
done < $F
