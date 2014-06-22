#!/bin/bash -x

#Network node
NET_PUB='10.0.1.2'
NET_PRI='10.0.10.2'

#Controller node
CONT_PUB='10.0.1.3'
CONT_PRI='10.0.10.3'

#Computer node
COMP_PUB='10.0.1.4'
COMP_PRI='10.0.10.4'

##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'


NIC1='eth0'

#compute_node's Public IP address
sed -i.org -e "s/CONFIG_NOVA_COMPUTE_HOSTS=[a-zA-Z0-9]\+\/CONFIG_NOVA_COMPUTE_HOSTS=$NET_PRI/" ./test_ans.txt
sed -i.org -e "s/CONFIG_NEUTRON_OVS_TUNNEL_RANGES=[a-zA-Z0-9]\+/CONFIG_NEUTRON_OVS_TUNNEL_RANGES=1\:1000/" ./test_ans.txt
