#!/bin/bash

cat << _DNS_ >> /etc/resolv.conf
nameserver 192.168.1.147
search ryosukemorino.com
_DNS_

