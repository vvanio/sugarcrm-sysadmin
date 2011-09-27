#!/usr/bin/env bash

VERBOSE=0

#
# Initialize symlinks from .symlinks
#

do_symlink() # $path $srcdir
{
	# If symlink exists continue
	[ -L "$1" ] && continue;
	[ -e "$1" ] && (rm $1 || (echo "Path exists: $1" && exit 4));
	if test ! -e "$2/$1"
	then
		echo "Symlink path $2/$1 doesn't exist"
		exit 5
	else
		dir=$(dirname $1)
		[ "$dir" = "." ] && dir = "./";
		if test ! -d $dir
		then
			mkdir -p "$dir"
			echo "Folder: $dir created"
		fi
		# Create the symlink with a relative path
		ln -s "$(echo $dir | sed -e s/[a-zA-Z\_-]*/../g)/$2/$1" "$1"
		echo "$1 -> $2/$1"
	fi
}

### Main

if test ! -e sugar_version.php
then
	echo "This script must be run from a sugar installation root folder. ";
	exit 3
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
			exit 2;
		fi
	fi
else
	echo "Usage: $0 [file]"
	exit 1
fi

# Read all lines
# Whitespace determines 'do_symlink' arguments, paths cannot contain any spaces!
SRCDIR=$(dirname $F)
if test -z "$SRCDIR"; then SRCDIR=.; fi
i=0
while read line; do
	# count lines (debugging)
	i=$(expr $i + 1);
	# ignore blanks and comments
	[ -z "$(echo $line|sed 's/\s\+//')" -o "${line:0:1}" = "#" ] && continue;
	# debug print
	[ "$VERBOSE" -gt 0 ] && echo 1=$1, SRCDIR=$SRCDIR, line=$line
	# invoke symlink routine
	if test ! -e "$SRCDIR/$line"; then
		echo "! Non-existant path '$line', given at $F:$i"
	else
		do_symlink $line $SRCDIR
	fi
done < $F

echo OK.
