#!/bin/bash
H_DEFAULT='local.localdomain'

#hostname
if [ $HOSTNAME != $H_DEFAULT ]; then
    echo "$IP $HOST $DOMAIN" >> /etc/hosts
    echo "apply hostname!"
fi 
echo "yey!";
