#!/bin/bash -x 

#Description:
#   Continuous script from ready_stack.sh
#   install&configure basics  of RDO Icehouse (multi-node)



#variables
#Dashboard admin password
PASS='admin'
#MYSQL_PASS='arcueid\$0326'

#NIC
NIC1='eth1'     #PUBLIC NETWORK NIC
NIC2='eth2'     #PRIVATE NETWORK NIC
#NIC3='eth3'

#Static IP
#IPADDR='192.168.1.244'
#NETMASK='255.255.255.0'
#GATEWAY='192.168.1.1'

#Controller node
CONT_PUB='10.0.0.11'
CONT_PRI='10.0.1.11'

#Network node
NET_PUB='10.0.0.21'
NET_PRI='10.0.1.21'

#Computer node
COMP_PUB='10.0.0.31'
COMP_PRI='10.0.1.31'



#HOSTS
IP=$(hostname -I)
HOST=$(hostname -s)
DOMAIN=$(hostname)
H_DEFAULT='localhost.localdomain'

##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'

#SUBNET1='172.16.13.0/24'


#Check ROOT permission
if [[ $UID != 0 ]]; then
    echo -e "${COLOR_RED}Please run this script as root or sudo!${COLOR_DEFAULT}"
    exit 1 
else
    echo -e "${COLOR_LIGHT_BLUE}ROOT/SUDO run\t\t\t${COLOR_LIGHT_GREEN}[OK]${COLOR_DEFAULT}"
    echo -e "${COLOR_RED}Network Information${COLOR_DEFAULT}"

    echo -e "${YELLOW}Network Node${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PUBLIC  | $NIC1: ${COLOR_YELLOW}$NET_PUB${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PRIVATE | $NIC2: ${COLOR_YELLOW}$NET_PRI${COLOR_DEFAULT}"

    echo -e "${YELLOW}Compute Node${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PUBLIC  | $NIC1\: ${COLOR_YELLOW}$COMP_PUB${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PRIVATE | $NIC2\: ${COLOR_YELLOW}$COMP_PRI${COLOR_DEFAULT}"

    echo -e "${YELLOW}Controller  Node${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PUBLIC  | $NIC1: ${COLOR_YELLOW}$CONT_PUB${COLOR_DEFAULT}"
    echo -e "${COLOR_LIGHT_GREEN}PRIVATE | $NIC2: ${COLOR_YELLOW}$CONT_PRI${COLOR_DEFAULT}"



    #hostname
    if [ $HOSTNAME != $H_DEFAULT ]; then
        echo "$IP $HOST $DOMAIN" >> /etc/hosts
    fi  



    #----------Install RDO-------------------
    /usr/bin/yum -y install openstack-packstack
    
    
    #Create answer file
    /usr/bin/packstack --gen-answer-file=/root/answer.txt
    
    #Edit Answer file
    /bin/sed -i.org -e "s/CONFIG_CONTROLLER_HOST=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_CONTROLLER_HOST=$CONT_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_COMPUTE_HOSTS=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_COMPUTE_HOSTS=$COMP_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NETWORK_HOSTS=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_NETWORK_HOSTS=$NET_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_MYSQL_HOST=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_MYSQL_HOST=$CONT_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_AMQP_HOST=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_AMQP_HOST=$CONT_PRI/" /root/answer.txt

    /bin/sed -i.org -e "s/CONFIG_MONGODB_HOST=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/CONFIG_MONGODB_HOST=$CONT_PRI/" /root/answer.txt

    #NOVA CONFIG
    /bin/echo "CONFIG_NOVA_COMPUTE_HOSTS=$NET_PRI" >> /root/answer.txt
#    /bin/sed -i.org -e "s/CONFIG_NOVA_COMPUTE_HOSTS=[a-zA-Z0-9]\+/CONFIG_NOVA_COMPUTE_HOSTS=$NET_PRI/" /root/answer.txt


    #GRE options
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_OVS_TENANT_NETWORK_TYPE=[a-zA-Z0-9]\+/CONFIG_NEUTRON_OVS_TENANT_NETWORK_TYPE=gre/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_OVS_TUNNEL_RANGES=[a-zA-Z0-9]*/CONFIG_NEUTRON_OVS_TUNNEL_RANGES=1\:1000/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_OVS_TUNNEL_IF=[a-zA-Z0-9]\+/CONFIG_NEUTRON_OVS_TUNNEL_IF=$NIC2/" /root/answer.txt
    

    /bin/sed -i.org -e "s/CONFIG_NOVA_COMPUTE_PRIVIF=[a-zA-Z0-9]\+/CONFIG_NOVA_COMPUTE_PRIVIF=$NIC2/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NOVA_NETWORK_PRIVIF=[a-zA-Z0-9]\+/CONFIG_NOVA_NETWORK_PRIVIF=$NIC2/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NOVA_NETWORK_PUBIF=[a-zA-Z0-9]\+/CONFIG_NOVA_NETWORK_PUBIF=$NIC1/" /root/answer.txt
    
    #Network node
    /bin/sed -i.org -e "s/CONFIG_NOVA_NETWORK_HOSTS=[a-zA-Z0-9]\+/CONFIG_NOVA_NETWORK_HOSTS=$NET_PRI/" /root/answer.txt 
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_SERVER_HOST=[a-zA-Z0-9]\+/CONFIG_NEUTRON_SERVER_HOST=$NET_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_L3_HOSTS=[a-zA-Z0-9]\+/CONFIG_NEUTRON_L3_HOSTS=$NET_PRI/" /root/answer.txt
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_DHCP_HOSTS=[a-zA-Z0-9]\+/CONFIG_NEUTRON_DHCP_HOSTS=$NET_PRI/" /root/answer.txt 
    /bin/sed -i.org -e "s/CONFIG_NEUTRON_METADATA_HOSTS=[a-zA-Z0-9]\+/CONFIG_NEUTRON_METADATA_HOSTS=$NET_PRI/" /root/answer.txt
   

    #KEYSTONE CONFIG -admin password
    /bin/sed -i.org -e "s/CONFIG_KEYSTONE_ADMIN_PW=[a-zA-Z0-9]\+/CONFIG_KEYSTONE_ADMIN_PW=$PASS/" /root/answer.txt
    
    #disable DEMO account/network
    /bin/sed -i.org -e 's/CONFIG_PROVISION_DEMO=[a-zA-Z0-9]\+/CONFIG_PROVISION_DEMO=n/' /root/answer.txt
    
    #disable CEILOMETER installation
    /bin/sed -i.org -e "s/CONFIG_CEILOMETER_INSTALL=y/CONFIG_CEILOMETER_INSTALL=n/" /root/answer.txt

    #disable NAGIO installation
    /bin/sed -i.org -e "s/CONFIG_NAGIOS_INSTALL=y/CONFIG_NAGIOS_INSTALL=n/" /root/answer.txt


    #Run packstack with customized answer file
    /usr/bin/packstack --answer-file=/root/answer.txt
    
    #-----------Create NIC Configuration files-----------------
    #config backup
    /bin/cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.org
    
    
    #HWaddr ID of NIC1 (public network)
    HW_NIC1=`ifconfig $NIC1 | awk '/HWaddr/ {print $5}'`
    /bin/cp ./conf/ifcfg-public.temp ./conf/ifcfg-$NIC1
    /bin/sed -i.org -e "s/HWADDR=/HWADDR=\"$HW_NIC1\"/g" ./conf/ifcfg-eth0
    
    #Bridge setup
    /bin/cp ./conf/ifcfg-bridge.temp ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/IPADDR=/IPADDR=$IPADDR/g" ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/GATEWAY=/GATEWAY=$GATEWAY/g" ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/NETMASK=/NETMASK=$NETMASK/g" ./conf/ifcfg-br-ex
    
    #copy configs
    /bin/cp -f ./conf/ifcfg-$NIC1 /etc/sysconfig/network-scripts/ifcfg-$NIC1
    /bin/cp -f ./conf/ifcfg-br-ex /etc/sysconfig/network-scripts/ifcfg-br-ex
    
    #neutron plugin setup
    echo "network_vlan_ranges = physnet1" >> /etc/neutron/plugin.ini
    echo "bridge_mappings = physnet1:br-ex" >> /etc/neutron/plugin.ini
    echo -e "${COLOR_RED}Instaltion completed"


#Create basic neutron network
    
    source /root/keystonerc_admin
    neutron router-create router1 #create router1 and get router1 id
    
    ROUTER_ID=$(neutron router-show router1 | grep -i tenant_id | awk -F '|' '{print $3}')
    ADMIN_ID=$(keystone tenant-list | grep admin | awk -F '|' '{print $2}') #Case public

    neutron net-create public --tenant-id $ADMIN_ID --router:external=True
    #Assign IP address rage on networks
    #neutron subnet-create ext-net \
    #  --allocation-pool start=FLOATING_IP_START,end=FLOATING_IP_END \
    #  --gateway=EXTERNAL_INTERFACE_GATEWAY --enable_dhcp=False \
    #  EXTERNAL_INTERFACE_CIDR
    neutron subnet-create public  --name public_subnet01 --allocation-pool start=192.168.1.200,end=192.168.1.224 --gateway=192.168.1.1 --enable_dhcp=False 192.168.1.0/24
    #Case private
    #neutron net-create private-net --tenant-id $routerid --shared
    neutron net-create private-net --tenant-id $ADMIN_ID
    neutron subnet-create private-net 10.0.0.0/24 --name private_subnet01 --enable_dhcp=True --gateway=10.0.0.1 --dns-nameserver 8.8.8.8 
    neutron net-update private-net --shared

    #Assing router1 gateway as public network
    neutron router-gateway-set router1 public
    neutron router-interface-add router1 subnet=private_subnet01 #connect private network with router1


    #Change hypervisor to kvm    
    /bin/sed -i.org -e "s/libvirt_type=qemu/libvirt_type=kvm/" /etc/nova/nova.conf
    

    #/sbin/shutdown -r -t now
fi #check root
