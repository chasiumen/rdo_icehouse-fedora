#!/bin/bash -x
user='morinor'


COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'

#Check ROOT permission
if [[ $UID != 0 ]]; then
    echo -e "${COLOR_RED}Please run this script as root or sudo!${COLOR_DEFAULT}"
    exit 1 
else

    #make bin directory
    /bin/mkdir /home/$user/bin
    
    #copy bash profile
    /bin/cp /home/$user/.bashrc /home/$user/.bashrc.old
    /bin/cp -f  ./conf/.bashrc /home/$user/.bashrc
    
    #install vim
    /usr/bin/yum install -y vim-enhanced
    
    #copy vim profile
    /bin/cp -f ./conf/.vimrc /home/$user/.vimrc
    
    #cp authorized_keys
    /bin/cp -f ./conf/authorized_keys /home/$user/.ssh/
    
    #set permission
    /bin/chmod 700 /home/$user/.ssh
    /bin/chmod 600 /home/$user/.ssh/authorized_keys
    
    #Change Ethernet interface names to ethX
    /bin/sed -i.org -e "s/rhgb quiet/net.ifnames=0 biosdevname=0/" /etc/default/grub 
    /bin/cp /boot/grub2/grub.cf /boot/grub2/grub.cf.old
    /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cf



    echo -e "${COLOR_LIGHT_BLUE}$user's personal configuration is completed.${COLOR_DEFAULT}"
    echo -e "${COLOR_RED}Please reboot the system to apply all of the configuration${COLOR_DEFAULT}"
     
fi
