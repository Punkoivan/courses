#Under GPL2+
CONF=/etc/httpd/conf/httpd.conf 
IP=192.168.1.18
PORT=$(grep  -e "BalancerMember" ${CONF} | grep -o ":[0-9]*" | grep -o [0-9]* |tail -n 1)
NEWPORT=$((PORT+1))
STRING=$(cat ${CONF} | grep -n -e "BalancerMember" |grep -o -e "^[0-9]*" |tail -n 1)
NEWSTRING=$((STRING+1))
BALQUANT=$(grep -c -e "Balancer" ${CONF})
NEWNAME=$((BALQUANT+1))
sed -i "${NEWSTRING}i\BalancerMember http://${IP}:${NEWPORT}" ${CONF}
echo "New balancer activating at ${IP}:${NEWPORT}..."
service httpd restart 2>/dev/null
echo "running docker container named apache${NEWNAME} and port mapping ${NEWPORT}:80, based on apache image..."
ssh root@${IP} "docker run --name apache${NEWNAME} --restart=always -it -d -v /root/app1/:/var/www/html/ -p ${NEWPORT}:80 apache" 
echo "Done!"

#Created by Punko <Punkoivan@yandex.ru> on 18.05.2016
