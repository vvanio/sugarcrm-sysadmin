#!/bin/bash
# For those who use exuberant ctags to navigate through their working trees.
# Adapted to use with GIT/SVN versioned Sugar installations

PWD=$(pwd)
TAGS=$1
if test -z "$TAGS"
then 
	TAGS=$PWD/.tags
fi

if test ! -d $(dirname "$TAGS")
then
	echo "Error" >&2
	exit 1
fi

# FIXME: can index JS? 
echo "$PWD $ ctags -f $TAGS" >&2
exec ctags \
		-f $TAGS
		-h ".php" -R \
		--exclude="\.git" \
		--exclude="\.svn" \
		--totals=yes \
		--tag-relative=yes \
		--PHP-kinds=+cf 

#		--regex-PHP='/abstract class ([^ ]*)/\1/c/' \
#		--regex-PHP='/interface ([^ ]*)/\1/c/' \
#		--regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'

