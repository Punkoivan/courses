#under GPL2+
CONF=/etc/httpd/conf/httpd.conf
IP=192.168.1.18
NUMBER=$(grep -c "BalancerMember" ${CONF})
STRING=$(cat ${CONF} | grep -n -e "BalancerMember" |grep -o -e "^[0-9]*" |tail -n 1)
echo "Deleting balancer member..."
sed -i -e "${STRING}d" $CONF
service httpd restart 2>/dev/null
echo "Deleting docker container named:"
ssh root@${IP} "docker rm -f apache${NUMBER}"
echo "Done!"
#Created by Punko <Punkoivan@yandex.ru> on 18.05.2016

