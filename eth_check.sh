#!/bin/bash
#Filename: eth_check.sh
# Quick check for simple mistakes in order to avoid unexpectable issues after restarts 
# (check ONBOOT/GATEWAY/HWADDR on all servers of the instalation)
# with nice color output and formating 
# Tested on RHEL 6.5

for i in `mysql -uroot porta-configurator -sse "select ip from Servers"`
do
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n====== $h $i ======\n"
    rsh_porta.sh $i '
        red=`echo -en "\e[31m"` 
        green=`echo -en "\e[32m"`
        normal=`echo -en "\e[0m"`
        lightyellow=`echo -en "\e[93m"`
        if [ $(grep -qi gateway /etc/sysconfig/network; echo "$?") -eq 0 ]
            then
                printf "No GATEWAY in /etc/sysconfig/network\t${green}[OK]${normal}\n"
            else
                printf "GATEWAY in /etc/sysconfig/network\t${red}[FAIL]${normal}\n"
        fi
        echo "---------------------------"
        for i in $(ifconfig | grep Link | egrep -vi "inet|lo|vip" | cut -d" " -f 1)
        do
            printf "Interface : ${lightyellow}$i${normal}\n"
            if [ $(grep -qi ^hwaddr /etc/sysconfig/network-scripts/ifcfg-$i; echo "$?") -eq 0 ]
            then
                printf "HWADDR :\t${green}[OK]${normal}\n"
            else
                printf "HWaddr is not present\t${red}[FAIL]${normal} $(grep -i hwaddr /etc/sysconfig/network-scripts/ifcfg-$i)\n"
            fi
            sleep 0.2
            if [ $(grep -qi ^onboot=yes /etc/sysconfig/network-scripts/ifcfg-$i; echo "$?") -eq 0 ]
            then
                printf "ONBOOT :\t${green}[OK]${normal}\n"
            else
                printf "onboot=yes is not present\t${red}[FAIL]${normal} $(grep -i onboot /etc/sysconfig/network-scripts/ifcfg-$i)\n"
            fi
            sleep 0.2
            if [ $(grep -qi ^gateway /etc/sysconfig/network-scripts/ifcfg-$i; echo "$?") -eq 0 ]
            then
                printf "gateway is present\t${red}[FAIL]${normal} $(grep -i gateway /etc/sysconfig/network-scripts/ifcfg-$i)\n"
            else
                printf "GATEWAY:\t${green}[OK]${normal}\n"
            fi
            echo "---------------------------"
            sleep 0.2
        done'
done
