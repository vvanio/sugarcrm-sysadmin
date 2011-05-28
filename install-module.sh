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
	echo "Account file has no admin/password variables."
	exit -4
fi


ZIP=$2

if test -z "$ZIP" -o ! -f "$ZIP" -o -z "$(echo $ZIP|grep '^.*\.zip$' -)";
then
	echo "Need name of ZIP file to install"
	exit -5
fi

if test -n "$(echo $ZIP|grep ',')";
then
  echo "Path may not contain ',': $ZIP";
  exit -6
fi

if test -z "$lang"
then
	lang=en_us
	lang=nl_nl
	echo "Setting language to $lang"
fi

if test -z "$sugar_version"
then
	sugar_version=5
	echo "Setting sugar version to $sugar_version"
fi


echo "Logging into SugarCRM, and installing $ZIP on $SUGARHOST "\
	"(version $sugar_version, language $lang)"


login()
{
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
install_sugar5()
{
  echo "Installing $2 on //$1"
  filepath=$2;
  filename=$(basename $filepath);
  curl "http://$1/index.php?module=Administration&view=module&action=UpgradeWizard" \
    \
    -s -S --fail \
    -b cookiejar \
    \
    -F upgrade_zip=@"$filepath;type=application/zip" \
    -F upgrade_zip_escaped="$filename" \
    -F run=upload \
    \
    |elinks -dump 1 -no-references
  #  --trace-ascii - \

  # XXX: the rest of the installation needs to go by hand,
  # b/c it is kind hard getting the ID's from the hidden form
  # A JS testing/automation framework would be preferable
}
login
install_sugar$sugar_version $SUGARHOST $ZIP

