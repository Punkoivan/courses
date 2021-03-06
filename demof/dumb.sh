#!/bin/bash
LAST_NODE=$(tac Vagrantfile | grep -m 1 -e "node[0-9]" |grep -m 1 -o -e "[0-9]" | tail -n 1)
STRING=$(grep -n "end" Vagrantfile |tail -n 3|head -n 1 |grep -o -e "[0-9]*")
NEW_STRING=$((STRING+2))
NEW_NODE=$((LAST_NODE+1))
VAGRANT_HOME=./Vagrantfile
NEW_NODE_IP=$(tac ${VAGRANT_HOME} | grep -m 1 -o -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
PORT=$(tac Vagrantfile | grep -m 1 -e "guest" | grep -o -E "[0-9]{4}")
sed -i '$d' ${VAGRANT_HOME}
cat ${VAGRANT_HOME} |grep -A 2 node${LAST_NODE} | sed -e "s/${LAST_NODE}/${NEW_NODE}/g" >> ${VAGRANT_HOME}
echo end >> ${VAGRANT_HOME}
vagrant up node${NEW_NODE}
