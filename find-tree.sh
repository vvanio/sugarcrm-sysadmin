#!/bin/bash
PATTERN=$1
find ./ \
  -not -ipath *.svn* -and \
  -not -ipath '*cache*' -and \
  -not -ipath '*custom/modulebuilder*' \
  -not -iname '*.md5' -and -iwholename $PATTERN
exit
FLAGS=-not\ -ipath\ *.svn*\ -a\ -not\ -ipath\ \'*cache*\'
#FLAGS+=" -not -iname '*.js' -a -not -iname \*.md5 "
#FLAGS+=\ -a
echo "find ./ ${FLAGS} -ipath $PATTERN"
find ./ ${FLAGS} -ipath $PATTERN
#FIND=find\ ./\ ${FLAGS}\ -iname\ $PATTERN
echo '#' $FIND
