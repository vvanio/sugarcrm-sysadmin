#!/bin/bash

SUGARHOST=$1

if test -z "$SUGARHOST"
then
	echo "Please pass the hostname of the SugarCRM installation for repair/rebuild"
	echo "I.e.: repair-rebuild.sh sugarcrm.local"
	exit -2
fi

if test ! -e "account.$SUGARHOST.sh"
then
	echo "Need account credentials in 'account.$SUGARHOST.sh'"
	exit -3
fi

source "account.$SUGARHOST.sh"

if test -z "$user" -o -z "$password"
then
	echo "Account file has no user/password variables."
	exit -4
fi
# Set lang= or sugar_version= in account.*.sh too!

if test -z "$lang"
then 
	#lang=en_us
	lang=nl_nl
	echo "Setting language to $lang"
fi

if test -z "$sugar_version"
then
	sugar_version=5
	echo "Setting sugar version to $sugar_version"
fi

# main.rst include
login()
{
echo "Logging into SugarCRM at $SUGARHOST"
R=$(curl "http://$SUGARHOST/index.php" \
	-F user_name=$user -F user_password=$password \
	-F login_language=$lang -F login_theme=Sugar \
	\
	-F module="Users" \
	-F action="Authenticate" \
	-F cant_login="" \
	-F login_module="Home" \
	-F login_action="index" \
	-F login_record="" \
	-L \
	-c cookiejar \
 	-s -S \
	\
  | grep user_password)
if [ -n "$R" ]; then return 1; else return 0; fi
#	| elinks -dump 1 -no-references
#	> /dev/null
}
# /main.rst include
handle_alter_query()
{
	SQL=$(cat $SUGARHOST.last-rr-call | grep -o '^\(ALTER\|CREATE\).*');
	if [ -n "$SQL" ]
	then
	  echo
	  echo "Vardefs have changed:"
	  grep -o '^\(CREATE\|ALTER\).*' $SUGARHOST.last-rr-call
	  read -p "Execute SQL? [yN] " EXECSQL
	  if [ "$EXECSQL" == 'y' ];
	  then
		curl "http://$SUGARHOST/index.php?module=Administration&action=repairDatabase" \
		  -F raction=Execute \
		  -F sql="$SQL" \
		  -s -S \
		  -b cookiejar \
		  -o $SUGARHOST.last-rr-call \
		  --write-out %{http_code}
		cat $SUGARHOST.last-rr-call \
		  | elinks -dump 1 -no-references
	  # grep 'Database tables are synced with vardefs
	  fi
	fi
}
repair_rebuild_sugar5()
{
	echo "Calling repair/rebuild for SugarCRM 5 on $SUGARHOST ";
	curl "http://$SUGARHOST/index.php" \
		-F action=QuickRepairAndRebuild \
		-F subaction=repairAndClearAll \
		-F module=Administration \
		-F "repair_module[]"="All+Modules" \
		-F "selected_actions[]"="clearTpls" \
		-F "selected_actions[]"="clearJsFiles" \
		-F "selected_actions[]"="clearVardefs" \
		-F "selected_actions[]"="clearJsLangFiles" \
		-F "selected_actions[]"="clearDashlets" \
		-F "selected_actions[]"="clearSugarFeedCache" \
		-F "selected_actions[]"="clearThemeCache" \
		-F "selected_actions[]"="rebuildAuditTables" \
		-F "selected_actions[]"="rebuildExtensions" \
		-F "selected_actions[]"="clearLangFiles" \
		-F "selected_actions[]"="clearSearchCache" \
		-F "selected_actions[]"="clearPDFFontCache" \
		-F "selected_actions[]"="repairDatabase" \
		-s -S \
		-b cookiejar \
		-o $SUGARHOST.last-rr-call
	cat $SUGARHOST.last-rr-call | elinks -dump 1 -no-references
	handle_alter_query
}
repair_rebuild_sugar6()
{
	echo "Calling repair/rebuild for SugarCRM 6 on $SUGARHOST ";
	curl "http://$SUGARHOST/index.php" \
		-F module=Administration \
		-F action=repair \
		\
		-s -S \
		-b cookiejar \
		-o $SUGARHOST.last-rr-call \
		--write-out %{http_code}
	cat $SUGARHOST.last-rr-call | elinks -dump 1 -no-references
	handle_alter_query
}

# Main
login
if [ $? != 0 ]; then echo "Could not log in, check credentials" ; else
	repair_rebuild_sugar$sugar_version
fi;
