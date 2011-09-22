#!/usr/bin/env bash

#
# Check if .symlinks is complete and not missing paths
#

BUILD_DIR=.
if test -z "$1"
then
	EXTERNAL=../custom_include
else
	EXTERNAL=$1
fi

if test ! -e $EXTERNAL/.symlinks
then
	echo "First argument should point be submodule directory. "
	exit 1
fi

if test ! -e sugar_version.php
then
	echo "This script must be run from a sugar installation directory. ";
	exit 1
fi

echo "Testing if $(dirname $BUILD_DIR) is correctly symlinked to $EXTERNAL"

L=${#EXTERNAL}
find $EXTERNAL -type f ! -ipath '*.git*' | \
	while read f; do \
		O=$(expr $L - ${#f});\
		F=${f:$O};F=${F#/};\
		#echo F=$F, f=$f
		[ ! -e "$F" ] && echo "! Missing link to path: $f" && continue; \
	done

echo
echo "Checking wether all lines from $EXTERNAL/.symlinks exists. "

i=0
while read line; do
	i=$(expr $i + 1);
	# ignore blanks and comments
	if test -n "$line" -a "${line:0:1}" != "#"; then
		if test -z "$EXTERNAL"; then EXTERNAL=.; fi
		if test ! -e "$EXTERNAL/$line"; then
			echo "! Non-existant path $line, given at $EXTERNAL/.symlinks:$i"
		fi
	fi
done < $EXTERNAL/.symlinks

echo OK.
