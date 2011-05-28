#!/bin/bash

SUGARHOST=$1

if test -z "$SUGARHOST"
then
	echo "Please pass the hostname of the SugarCRM installation for repair/rebuild"
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
	echo "Account file has no admin/password variables."
	exit -4
fi

if test -z "$lang"
then
	lang=en_us
	echo "# Setting language to $lang"
fi

if test -z "$sugar_version"
then
	sugar_version=5
	echo "# Setting sugar version to $sugar_version"
fi

login()
{
echo "# Logging into SugarCRM on $SUGARHOST "\
	"(version $sugar_version, language $lang)"
curl "http://$SUGARHOST/index.php" \
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
	-s -S \
	-c cookiejar \
	> /dev/null
}
test_profile()
{
#PROFILE="time -f cpu%P\\\nelapsed%E\\\nreal%r\\\nuser%U\\\nsys%S"
PROFILE="time -f %E"
echo -n "$1,"
($PROFILE curl "http://$SUGARHOST/index.php" \
	\
	-F module="$1" \
	-F action="index" \
	\
	-b cookiejar -s 1> /dev/null) 2>&1
}
test_time()
{
	if test ! -e "modules.$SUGARHOST.list"
	then 
		print "No ./modules.$SUGARHOST.list file!" >&2
		exit 1
	fi
	echo "# Profiling index views for modules in ./modules.$MODULES.list";

	#MODULES=$(cat ./modules.list|tr ' ' '\n')
	MODULES=$(cat ./modules.$SUGARHOST.list)
	#REV=$(cd ~/workspace/Facio-CRM/;svn info|grep Revision|sed 's/^Revision://')
	DATETIME=$(date -u +%Y-%m-%dT%H:%M:%S)
	
	# XXX:BVB: output CSV?
	echo "Module,$DATETIME"
	#echo ",$REV"
	for module in $MODULES
	do
		test_profile $module
	done
}

login
test_time


