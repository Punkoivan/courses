IP=192.168.1.18
rsync -avz -e ssh ./app/ root@${IP}:/root/app1/
