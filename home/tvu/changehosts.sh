#!/bin/sh
file=/etc/hosts
echo "begin change ${file}"
ip=`dig  +short eastus2.api.cognitive.microsoft.com|tail -n 1`
if [ -z ${ip} ]; then 
    echo "ip is empty"
    exit
fi
ipnum=${ip:0:1}

if [ "$ipnum" -gt 0 ];then
        echo ${ipnum}
else
        echo "not number"
        exit
fi
#sed -i '/localhost/d' /etc/hosts;
#sed -i '/tvunetworks.com/d' /etc/hosts
sed -i '/eastus2.api.cognitive.microsoft.com/d' /etc/hosts;

#echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" >> ${file}
#echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> ${file}
echo "${ip} eastus2.api.cognitive.microsoft.com" >> ${file}

#if [ $# == 2 ] && [ $2 = "test" ];then
#sed -i '/tvunetworks.com/d' /etc/hosts
#echo '
#10.12.22.93 mediamind.tvunetworks.com
#10.12.22.93 cc.tvunetworks.com
#10.12.22.95 msgpipe.tvunetworks.com
#10.12.22.95 heartbeat.tvunetworks.com
#10.12.22.100 transport.tvunetworks.com
#10.12.23.177 metadata.tvunetworks.com
#10.12.23.177 m1.tvunetworks.com
#10.12.23.177 search.tvunetworks.com
#10.12.23.177 s1.tvunetworks.com
#10.12.23.111 rtc.tvunetworks.com
#10.12.25.115 gus.tvunetworks.com' >> ${file}
#fi
#echo "*/5 * * * * sh /home/tvu/changehosts.sh" >> /var/spool/cron/root
echo ${ip}>/tmp/tmpchange.txt
