#!/bin/bash
STRING=$(grep -n "end" Vagrantfile |tail -n 3|head -n 1 |grep -o -e "[0-9]*")
NEWSTRING=$((STRING+2))
#echo $NEWSTRING

sed -i "${NEWSTRING}i\$(grep -A 2 "n.*3" Vagrantfile| sed -e "s/3/4/g")" Vagrantfile
