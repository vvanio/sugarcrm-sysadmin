#!/bin/bash

if test $(uname) != "Linux"
then
	echo "This is not a Linux box, exiting."
	exit 1
fi

old_UID=1000
new_UID=1000

old_staff_GID=50
new_staff_GID=20

old_dialout_GID=20
new_dialout_GID=19

echo "WARNING: this rewrites UID/GID settings for this filesystem. "
echo "sudo and other programs will FAIL if proper preparations have not been made!"
echo
echo "Make sure /etc/passwd contains a new line for UID $new_UID (old: $old_UID)"
echo "Make sure /etc/group contains:"
echo " - staff = GID $new_staff_GID (for old GID $old_staff_GID)"
echo " - dialout = GID $new_dialout_GID (for old GID $old_dialout_GID)"
echo

read -n 1 -p "Continue?" V
if test "$V" != "y" 
then
	echo "Cancelled, exiting. "
	exit 1
fi

cd /

echo find / -owner $old_UID -exec chown $new_UID {} +
sudo find / -owner $old_UID -exec chown $new_UID {} +
echo find / -group $old_dialout_GID -exec chgrp $new_dialout_GID {} +
sudo find / -group $old_dialout_GID -exec chgrp $new_dialout_GID {} +
echo find / -group $old_staff_GID -exec chgrp $new_staff_GID {} +
sudo find / -group $old_staff_GID -exec chgrp $new_staff_GID {} +

