#!/bin/bash
#
# Change all to:
#   www-data:staff
#   33:20
# And 0775/0664
#
# Except:
# - RCS paths
#

USER=33
if test -z "$1";
then
	GROUP="staff";
else
	GROUP=$1;
fi

# Set r/w for user and group 
#  ! \( -perm -u=rw -a -perm -g=rw -a -perm -o=r \) \
find ./ \
  ! \( -perm +u=rw -a -perm -g=rw -a -perm +o=r \) \
  -a ! \( -ipath '*/cache*' -o -iname '*.ext.php' \
	  -o -ipath '*/.git*' -o -ipath '*/.svn/*' \) \
  -a ! -type l \
  | while read p;
do
  sudo chmod ug+rw "$p";
  sudo chmod o+r "$p";
  echo "USER/GROUP r/w: $p"
done

# Dirs openable by other
find ./ \
  -type d -a ! -perm -o=x \
  | while read p
do
  sudo chmod +x "$p"
  echo "Dir o+x: $p"
done

# RCS paths
find ./ \
  \( -ipath '*/.git*' -o -ipath '*/.svn/*' \) \
  -a ! \( -perm -u=rw -a -perm -g=rw -a -perm -o=r \) \
  | while read f
do
  if test -d "$f";
  then
    sudo chmod 0775 "$f"
  else
    sudo chmod 0664 "$f"
  fi
  echo "RCS: $f"
done

# Cache and other generated paths
find ./ \
  \( -ipath '*/cache*' -o -iname '*.ext.php' \) \
  -a ! \( -ipath '*/.git*' -o -ipath '*/.svn/*' \) \
  -a ! \( -a -perm -u=rw -a -perm -g=rw -a -perm -o=r \) \
  | while read f;
do
	sudo chown $USER $f;
	sudo chgrp $GROUP $f;
	sudo chmod u+rw $f
	sudo chmod g+rw $f
	sudo chmod o+r $f
  echo "Cache: $f";
done

# Set USER/GROUP on all files
find ./ \
  ! \( -user $USER -a -group $GROUP  \) \
  -a \( ! -ipath '*/cache*' -a ! -iname '*.ext.php' \) \
  -a ! \( -ipath '*/.git*' -o -ipath '*/.svn/*' \) \
  | while read f;
do
  if test -L "$f"; then
    sudo chown $USER "$f"
    sudo chgrp -h $GROUP "$f"
  else
    sudo chown $USER "$f"
    sudo chgrp -h $GROUP "$f"
  fi
	echo "USER/GROUP: $f"
done

# Init cache dirs
for f in cache\
	cache/modules\
	cache/modules/*\
	cache/jsLanguage\
	cache/smarty\
	cache/smarty/*\
	cache/upload\
	cache/upload/*\
	cache/blowfish\
	cache/themes
do
  if test ! -e
  then
    mkdir -p $f
    sudo chgrp $GROUP $f
    sudo chown $USER $f
    echo "Created $f"
  fi
  sudo chmod g+sw $f
done

