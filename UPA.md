## Update Preparation Automation

#### 1) The first thing which can be automated is "Check license"
```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers;"` 
do 
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n----- $h $i -----\n"
    rsh_porta.sh $i 'checklicense'
done
```


#### 2) tt local files
```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers;"` 
do 
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n----- $h $i -----\n"
    rsh_porta.sh $i 'sudo updatedb && locate tt.local'
done
```

3) RADIUS info :

```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers where name like '%master%'"`
do
    echo -e "\n\n---Master server: $i---\n"
    rsh_porta.sh $i '
    radiusd info | egrep -i "radiusd|model|build|licen"
    echo " "
    rpm -qi radiusd | egrep "Ver|Rel|Dist|Type"|tr -s " " | sed "1,3 s/ /\n/3"'
done
```

#### 4) Check patches :
```bash
ver=$(env | grep -o "MR..\.." | tr -d MR | tr \. - )
for i in `mysql -uroot porta-configurator -sse "select ip from Servers;"`  
do   
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n----- $h $i -----\n"
    rsh_porta.sh $i '
        ver=$(env | grep -o "MR..\.." | tr -d MR | tr \. - )
        sudo /home/porta-configurator/pcup/update/bin/check_patches_f -o current_partition=mr$ver' 
done >> ~/check_patches_$ver.txt 
 
--------------- variant with mail ---------------
 
mymail=some_mail@gmail.com;\
for s in `mysql -uroot porta-configurator -sse 'select IP from Servers'`
do
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$s'"`
    echo -e "\n=========================\n$h ($s)\n=========================\n"
    rsh_porta.sh $s '
        ver=$(env | grep -o "MR..\.." | tr -d MR | tr \. - )
        sudo /home/porta-configurator/pcup/update/bin/check_patches_f -o current_partition=mr$ver'
done > ~/check_patches_$ver.txt;\
date | mail -s Check_pacthes_output -a ~/check_patches_$ver.txt $mymail
```

#### 5) Check Apache custom config files :
```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers where name like '%slave%' or name like  '%web%' or name like  '%um%'"`
do
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n----- $h $i -----\n"
    rsh_porta.sh $i '
    echo -e "-----The main conf :"
    grep "^Include" /etc/httpd/conf/httpd.conf
    echo -e "----------------\n"
    if [ -f ~/apache_configs.txt ] ; then sudo rm ~/apache_configs.txt; fi
    for i in $(ls --color=never /etc/httpd/conf.d/ | xargs echo ); do echo $i >> ~/apache_configs.txt; done 
    sleep 1
    echo -e "The custom files are the following:\n "
egrep -vi "apreq.conf|call-recording.httpd.conf|custom-repository.httpd.conf|deny.conf|fcgid.conf|pagespeed.conf|performance.conf|perl.conf|perl-HTML-Mason.conf|php.conf|porta-configurator.httpd.conf|porta-fcgid.conf|porta.httpd.conf|porta-um.httpd.conf|README|ssl.conf" ~/apache_configs.txt '
done
```

#### 6) Total network check :
```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers"`
do
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"`
    echo -e "\n====== $h $i ======\n"
    rsh_porta.sh $i '
        red=`echo -en "\e[31m"` 
        green=`echo -en "\e[32m"`
        normal=`echo -en "\e[0m"`
        echo -e "- - - ifconfig - - -\n"
        ifconfig  | sed -n "/^[a-z]\+/,+1p"
        echo "---------------------------"
        if [ $(grep -qi gateway /etc/sysconfig/network; echo "$?") -eq 0 ]
        then
            echo "${green}GATEWAY is present in the /etc/sysconfig/network - OK" && echo "${normal}"
        else
            echo "${red}GATEWAY is not present in the /etc/sysconfig/network - need to fix" && echo "${normal}"
        fi
        for i in $(ifconfig | grep Link | egrep -vi "inet|lo|vip" | cut -d" " -f 1)
        do
           echo -e "Interface : $i"
           egrep -i "HWADDR|onboot|gateway" /etc/sysconfig/network-scripts/ifcfg-$i
           echo "---------------------------"
           sleep 1
        done'
done
```

#### 7) Total backup of actual/current network configuration – uploaded to support-repo
```bash
#!/bin/bash
 
TIME_NOW=$(date +%T_%d-%m-%y)
for s in `mysql -uroot porta-configurator -sse 'select IP from Servers'`
do
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$s'"`
    echo -e "\n ----- $(hostname) / $h $s -----\n"
    rsh_porta.sh $s '
        echo -e " ======== CONFIG SETTINGS ========\n"
        ifconfig | grep -B1 inet
        echo -e "\n ======== IP ROUTE TABLE ========\n" 
        ip route show table main
        echo -e "----------\n"
        echo -e "\n ======== IPTABLES STATUS ========\n" 
        sudo service iptables status
        echo -e "\n ======== CONFIG SETTINGS ========\n" 
        grep ^ -H /etc/sysconfig/network
        echo -e "-----------"
        for i in $(ifconfig | grep Link | egrep -vi "inet|lo|vip" | cut -d" " -f 1)
            do
               echo -e "\n-----------\nInterface : $i\n-----------\n"
               grep ^ /etc/sysconfig/network-scripts/ifcfg-$i
            done'
done > ~/network_configuration_$TIME_NOW.txt
```

#### 8) Hardware check (tested RHEL 6.5 / DELL servers)
```bash
for i in `mysql -uroot porta-configurator -sse "select ip from Servers;"` 
do 
    h=`mysql -uroot porta-configurator -sse "select Name from Servers where IP='$i'"` 
    echo -e "\n----- $h $i -----\n" 
    rsh_porta.sh $i '
    IFS=":" read -a raid <<< "$(sudo megacli -ShowSummary -a0 | grep -i raid | tr -d " ")"
    slots=`sudo megacli -ShowSummary -a0 | grep -c Slot`
    IFS=":" read -a size <<< "$(sudo megacli -ShowSummary -a0 | grep -i size | tr -d " ")"
    IFS=":" read -a charge <<< "$(sudo megacli -AdpBbuCmd -aAll | grep -i rep | grep -i batt | tr -d " ")"
    /home/porta-configurator/bin/cfgctl.pl -c server_info -p acquire_netinfo=0 | egrep -i "CPU|RAM|RAID|HOST|MANUF|OS"
    printf "%-30s : %s\n" "${raid[0]}" "${raid[1]}"
    printf "%-30s : %s\n" "Slots" "$slots"
    printf "%-30s : %s\n" "${size[0]}" "${size[1]}"
    printf "%-30s : %s\n" "${charge[0]}" "${charge[1]}"
    '
done
```

####  Other info

```bash
9) Check Hardware Suitability
SERVER MODEL: 
printf "SERVER MODEL: $( sudo /usr/sbin/dmidecode | egrep "Product Name|Manufacturer" | head -2)\n" 
 
CPU INFO:
printf "Model name: $( cat /proc/cpuinfo | grep 'model name' | cut -d: -f2 | awk 'NR==1'  | tr -s ' ')\n" && printf "Physical processors: $( grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l)\n" && printf "Virtual processors: $( grep ^processor /proc/cpuinfo | wc -l)\n" && printf "Dual-core (or multi-core): $( grep 'cpu cores' /proc/cpuinfo | sort -u)\n"
 
RAM:
printf "Memory type: $( sudo dmidecode -t memory | grep "Type: DDR" | sort -u)\n" && printf "Number of memory modules: $( sudo dmidecode -t memory | grep "Size" | grep -c "MB")\n" && printf "Size of memory module: $( sudo dmidecode -t memory | grep "Size" | grep "MB" | sort -u)\n" && printf "Total size: $( mem=$(cat /proc/meminfo | head -n 1 | awk '/[0-9]/ {print $2}') && echo $[$mem/1024] MB)\n"
 
RAID,HDD INFO (Dell):
printf "$( sudo megacli -ShowSummary -a0 | grep "ProductName" | tr -s " ")\n" && printf "$( sudo megacli -AdpAllInfo -aALL | grep "Write Policy")\n" && printf "$( sudo megacli -LDInfo -Lall -aALL | egrep --color "Default Cache Policy|Current Cache Policy|Disk Cache Policy")\n" && printf "$( sudo megacli -LDInfo -Lall -aALL | grep "RAID Level")\n" && printf "$( sudo megacli -ShowSummary -a0 | egrep --color "RAID Level|Size" | sed s/^[[:space:]]*//)\n" && printf "Number of disks: $( sudo megacli -ShowSummary -a0 | grep -c "Slot" | sed s/^[[:space:]]*//)\n"
 
HP:
sudo hpacucli ctrl all show config detail
 
NIC INFO:
printf "List Of Network Cards: $( sudo lspci | egrep -i --color 'network|ethernet')\n"
for i in `ifconfig | egrep "eth|em|bond|vlan" | awk '{print $1}'`; do sudo ethtool $i | egrep "Settings for|Speed|Link";done
 
BATTERY INFO (Dell):
printf "BATTERY INFO (Dell):\n$( sudo megacli -AdpBbuCmd -GetBbuStatus -aALL | egrep --color "Voltage|Charging Status|Fully Charged" | tr -s ' ' | sed s/^[[:space:]]//)\n" && sudo megacli -AdpBbuCmd -aAll | egrep --color "State of char|Remaining Capacity:|Full Charge Capacity:|Design Cap"
```

