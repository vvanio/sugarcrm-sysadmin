#!/bin/bash
PATTERN=$1
shift 1
if test -n "$1"
then
	DIR=$1
else
	DIR=$(pwd)
fi
shift 1
if test -n "$*"
then
	FLAGS=$*
fi
#	  $DIR/custom/application/Ext/Include/modules.ext.php 
echo "Grepping for $PATTERN (extra flags: $FLAGS) at $DIR"
cd $DIR
grep -r $PATTERN \
  -I \
  --exclude './.git*' \
  --exclude './.svn*' \
  --exclude './custom/modulebuilder*' \
  --exclude 'dbschema.xml' \
  --exclude '*build*.js' \
  --exclude '*.md5' \
  --exclude '*.ext.php' \
  --exclude '*.log' $FLAGS  ./
#  | grep -v '\./\(tests\|cache\|tests\)\/'

