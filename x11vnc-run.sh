#!/bin/bash
PASSWD=$X11VNC_PASSWD
if test -z "$PASSWD"
then
	echo "Set X11VNC_PASSWD env var for password. "
	read -t 20 -p "Enter password now: " PASSWD
fi
if test -z "$PASSWD"
then
	PASSWD=testje
fi

x11vnc -repeat -gui tray -avahi -passwd $PASSWD -noxinerama -nomodtweak -display :0 -http

