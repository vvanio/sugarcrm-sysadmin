#!/bin/bash
pwd # print cwd
# XXX:BVB:Sugar theme dep.
for dir in cache/modules cache/dashlets cache/jsLanguage cache/smarty/templates_c cache/upload/upgrades/temp cache/themes/Sugar/js/
do
  echo "Removing all in dir $dir"
  sudo rm -r $dir/* 
  #find $dir -not -perm /g=w | while read f; do echo "Updating permissions of $f";sudo chmod g+w "$f"; done
done
#find ./cache/ -type d | while read d; do chmod ugo+rwsx $d; done
