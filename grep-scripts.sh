#!/bin/bash
PATTERN=$1
shift 1
if test -n "$*"
then
	FLAGS=$*
fi
rgrep $PATTERN ./ -I \
  --exclude-dir .git \
  --exclude-dir .svn \
  --exclude-dir cache \
  --exclude-dir custom/modulebuilder \
  --exclude 'dbschema.xml' \
  --exclude '*.md5' \
  --exclude '*.ext.php' \
  --exclude '*.log' $FLAGS


