#!/bin/bash -x
#Description:
#Runs Only on Fedora 20 64bit
#This script automatically sets up RDO installable environment
#such as kernel parameters, RDO repos, EPEL repos, and etc...



#------------VARIABLE------------
ARC=$(/bin/uname -m)

OS=$(cat /etc/redhat-release | awk -F ' ' '{print $1}')
VERSION=$(cat /etc/redhat-release | awk -F ' ' '{print $3}')
VER_REQ='20'

##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'



##----------PREPARATION-----------

#Check ROOT permission
if [[ $UID != 0 ]]; then
    echo -e "${COLOR_RED}Please run this script as root or sudo!${COLOR_DEFAULT}"
    exit 1
else
    echo -e "${COLOR_LIGHT_BLUE}ROOT/SUDO run\t\t\t${COLOR_LIGHT_GREEN}[OK]${COLOR_DEFAULT}"
    #Check OS version
    if [ $VERSION != $VER_REQ ] ; then
        echo -e  "${COLOR_RED}OS must be Fedora 20${COLOR_DEFAULT}"
        echo -e "${COLOR_LIGHT_GREEN}$OS, $VERSION${COLOR_DEFAULT}"
        exit 2
    else
        echo -e "${COLOR_LIGHT_BLUE}OS version\t\t\t${COLOR_LIGHT_GREEN}[OK]${COLOR_DEFAULT}"
        #Check system machine architectre
        if [ $ARC != 'x86_64' ]; then
            echo -e "${COLOR_RED}$ARC i386 compatible"
            echo "This program is only capable for x64 systems${COLOR_DEFAULT}"
            exit 3
        else
            #echo -e "${COLOR_LIGHT_BLUE}System ["${COLOR_RED} $ARC "]${COLOR_LIGHT_BLUE}detected..."
            echo -e "${COLOR_LIGHT_BLUE}System Architecture\t\t${COLOR_LIGHT_GREEN}[OK]${COLOR_DEFAULT}"
    
            ## Disable SELINUX
            /usr/sbin/setenforce 0
            /bin/sed -i.org -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
            
            ## Edit Kernel Parameter to enable Routing
            #change curernt parameter
            /bin/echo '1' > /proc/sys/net/ipv4/ip_forward
            /bin/echo '0' > /proc/sys/net/ipv4/conf/default/rp_filter
            
            #edit sysctl.conf
            /bin/sed -i.org -e 's/net.ipv4.ip_forward = 0/net.ipv4_ip_forward = 1/g' /etc/sysctl.conf
            /bin/sed -i.org -e 's/net.ipv4.conf.default.rp_filter = 1/net.ipv4.conf.default.rp_filter = 0/g' /etc/sysctl.conf
            
            #add more variable
            /bin/cat << _SYSCTLCONF_ >> /etc/sysctl.conf
            net.ipv4.conf.all.rp_filter = 0
            net.ipv4.conf.all.forwarding = 1
_SYSCTLCONF_

            
            #edit /etc/rc.local
            /bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables' >> /etc/rc.local
            /bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables' >> /etc/rc.local
            /bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables' >> /etc/rc.local
            
            /sbin/sysctl -p /etc/sysctl.conf

#            #add resolver (optional)
#            /bin/cp -f ./conf/add_resolv.sh /root/
#            /bin/cat << _DNS_ >> /etc/rc.d/rc.local
##add dns
#./root/add_resolv.sh
#_DNS_

            
            #add RDO Icehouse repo
            /usr/bin/yum install -y http://rdo.fedorapeople.org/rdo-release.rpm
           
            #install ntp
            /usr/bin/yum install -y ntp
            /usr/sbin/ntpdate server 0.fedora.pool.ntp.org
            /sbin/chkconfig ntpd on
            /sbin/service ntpd restart

            #sshd config | allow root login
            /bin/sed -i.org -e 's/PermitRootLogin no/PermitRootLogin yes/gi' /etc/ssh/sshd_config
            /sbin/service sshd reload


            #update package
            /usr/bin/yum -y update
            
            echo -e "${COLOR_LIGHT_BLUE}Inital configuration is done.${COLOR_DEFAULT}"
            echo -e "${COLOR_RED}Please reboot the system to apply all of the configuration${COLOR_DEFAULT}"

        fi #OS version check
    fi #system arch check
fi #root check
