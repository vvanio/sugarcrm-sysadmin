#!/bin/bash
MODDIR=custom/modules/
ls -d $MODDIR* | while read dirname
do
	for subdir in Language Vardefs Layoutdefs
	do
		if [ -d $dirname/Ext/$subdir ]
		then
#			echo $dirname/Ext/$subdir
#			ls -la $dirname/Ext/$subdir/*.ext.php
#			svn pg svn:ignore $dirname/Ext/$subdir
			svn ps svn:ignore "*.ext.php" $dirname/Ext/$subdir
		fi
	done
done
