#!/usr/bin/env bash

VERBOSE=0

#
# Initialize symlinks from .symlinks
#

do_symlink() # $sourcepath $targetdir
{
	# If symlink doesn't exist
	if test ! -L "$1"
	then
		if test -d "$1"
		then
			rm $1 || echo "Path exists: $1" && exit 1;
		fi
		if test ! -e "$2/$1"
		then
			echo "File/folder: $2/$1 doesn't exist"
			exit 1
		else
			dir=`dirname $1`
			if test ! -d $dir
			then
				mkdir -p "$dir"
				echo "Folder: $dir created"
			fi
			# Create the symlink with a relative path
			ln -s "$(echo $dir | sed -e s/[a-zA-Z\_-]*/../g)/$2/$1" "$1"
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
	if test ! -f $F; then
		if test -d $F -a -f $F/.symlinks
		then
			F=$F/.symlinks
		else
			echo "Missing symlinks file: $F";
			exit 1;
		fi
	fi
else
	echo "Usage: $0 [file]"
	exit -1
fi

# Read all lines
# Whitespace determines 'do_symlink' arguments, paths cannot contain any spaces!
SRCDIR=$(dirname $F)
if test -z "$SRCDIR"; then SRCDIR=.; fi
i=0
while read line; do
	i=$(expr $i + 1);
	# ignore blanks and comments
	if test -n "$line" -a "${line:0:1}" != "#"; then
		[ "$VERBOSE" -gt 0 ] && echo 1=$1, SRCDIR=$SRCDIR, line=$line
		if test ! -e "$SRCDIR/$line"; then
			echo "! Non-existant path '$line', given at $F:$i"
		else
			do_symlink $line $SRCDIR
		fi
	fi
done < $F

echo OK.
