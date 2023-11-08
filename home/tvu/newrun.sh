#!/bin/bash ++++++

########################################################################
# the verison of R to update.
R_VERSION=0

# the version of MMA to update.
MMA_VERSION=0

# the environment of update.
# test china global
# default is global.
# Upgrade package will be downloaded by environment.

ENVIRONMENT=global

# the target of service.
# dev test prod
# default is prod.
# service's configuration will be installed by target.

TARGET=prod


function loginfo()
{
	echo -en "\e[32m\e[1m"
	echo $1
	echo -en "\e[0m"
}

function disable_nginx()
{
	echo "====================="
	loginfo "Disable nginx"
	echo "====================="
	systemctl disable nginx
	systemctl stop nginx
	if [ -d /newrootR ]; then
		if [ -f "/newrootR/usr/lib/systemd/system/nginx.service" ];then
			mv /newrootR/usr/lib/systemd/system/nginx.service /newrootR/usr/lib/systemd/system/nginx.service.bak;
		fi
		if [ -f "/newrootR/etc/init.d/nginx" ];then
			rm -rf /newrootR/etc/init.d/nginx*;
		fi
	fi
	
	if [ -f "/usr/lib/systemd/system/nginx.service" ];then
		mv /usr/lib/systemd/system/nginx.service /usr/lib/systemd/system/nginx.service.bak;
	fi
	if [ -f "/etc/init.d/nginx" ];then
		rm -rf /etc/init.d/nginx*;
	fi
	loginfo "Disable nginx DONE"
}

function patch_mma()
{
#systemctl stop tvu.r;
	echo "====================="
	loginfo "Apply mma patch"
	echo "====================="
	
	if [ -d /newrootR ];then
		pushd /newrootR/home/tvu/MMAPATCH;
	else
		pushd /home/tvu/MMAPATCH;
	fi
	
	if [ -d /newrootR/root/.toprc ];then
		rm -rf /newrootR/root/.toprc;
	fi
	
	if [ -d /root/.toprc ];then
		rm -rf /root/.toprc;
	fi
	
	if [ -d /newrootR/root/recordmem.sh ];then
		rm -rf /newrootR/root/recordmem.sh;
	fi
	
	if [ -d /root/recordmem.sh ];then
		rm -rf /root/recordmem.sh;
	fi
	
	if [ -d /newrootR ];then
		tar -C /newrootR -xhvf tvu-mma-$MMA_VERSION.tar.gz
		sudo chmod +x /newrootR/root/receiver_boot.sh
	else
		tar -C / -xhvf tvu-mma-$MMA_VERSION.tar.gz
		sudo chmod +x /root/receiver_boot.sh
	fi
	
	
	#rm -rf tvu-mma-$MMA_VERSION.tar.gz;
	rm -rf /opt/gcc-5*
	loginfo "tar mma patch Done"
	popd;
}

function enable_openresty()
{
	echo "====================="
	loginfo "Enable openresty"
	echo "====================="
	
	if [ -d /newrootR ];then
		/newrootR/sbin/chkconfig openresty on
		rm -f /newrootR/etc/rc.d/rc3.d/K15openresty
		rm -f /newrootR/etc/rc.d/rc4.d/K15openresty
		rm -f /newrootR/etc/rc.d/rc5.d/K15openresty
		
		ln -s ../init.d/openresty /newrootR/etc/rc.d/rc3.d/S85openresty
		ln -s ../init.d/openresty /newrootR/etc/rc.d/rc4.d/S85openresty
		ln -s ../init.d/openresty /newrootR/etc/rc.d/rc5.d/S85openresty
		
		mkdir -p /newrootR/usr/local/openresty/nginx/logs
	else
		/sbin/chkconfig openresty on
		mkdir -p /usr/local/openresty/nginx/logs
		systemctl enable openresty
	fi
	
	systemctl restart openresty
	
	loginfo "Enable openresty DONE"
}

function create_mp4tmp()
{
	loginfo "create_mp4tmp"
	
	if [ -d /newrootR ];then
		pushd /newrootR/home/tvu;
		bash setup.sh;
		popd
	else
		pushd /home/tvu;
		bash setup.sh;
		popd
	fi
	
	loginfo "create_mp4tmp Done"
}

function change_host()
{
	loginfo "change_host"
	if [ -d /newrootR ];then
		pushd /newrootR/home/tvu/MMAPATCH/home/tvu;
		chmod a+x changehosts.sh;
		bash changehosts.sh;
		popd
		sed -i '/cron.min/d' /newrootR/etc/crontab;
		echo "*/5 *   * * *   root    run-parts /etc/cron.min" >> /newrootR/etc/crontab;
	
		if [ ! -d "/newrootR/etc/cron.min" ]; then
			mkdir -p /newrootR/etc/cron.min
		fi

		if [ -f "/newrootR/etc/cron.min/changehosts" ];then
			rm -rf /newrootR/etc/cron.min/changehosts;
		fi

		cp /newrootR/home/tvu/MMAPATCH/home/tvu/changehosts.sh /newrootR/etc/cron.min/changehosts;
		chmod a+x /newrootR/etc/cron.min/changehosts;
	
	else
		pushd /home/tvu/MMAPATCH/home/tvu;
		chmod a+x changehosts.sh;
		bash changehosts.sh;
		popd
		sed -i '/cron.min/d' /etc/crontab;
		echo "*/5 *   * * *   root    run-parts /etc/cron.min" >> /etc/crontab;
	
		if [ ! -d "/etc/cron.min" ]; then
			mkdir -p /etc/cron.min
		fi

		if [ -f "/etc/cron.min/changehosts" ];then
			rm -rf /etc/cron.min/changehosts;
		fi

		cp /home/tvu/MMAPATCH/home/tvu/changehosts.sh /etc/cron.min/changehosts;
		chmod a+x /etc/cron.min/changehosts;
	fi
}

function enable_tvu264()
{
	loginfo "enable_tvu264"
	if [ -d /newrootR ];then
		pushd /newrootR/opt/tvu/R/ExEncoder30;
		chmod a+x TVU264.exe;
		rm -rf libmfx* libva*;
		popd;

		pushd /newrootR/opt/tvu/R/WebRTC;
		chmod a+x peerclient;
		popd;
		
		chmod a+x /newrootR/usr/bin/gm
	else
		pushd /opt/tvu/R/ExEncoder30;
		chmod a+x TVU264.exe;
		rm -rf libmfx* libva*;
		popd;

		pushd /opt/tvu/R/WebRTC;
		chmod a+x peerclient;
		popd;
		
		chmod a+x /usr/bin/gm
	fi
}

function enable_switcher()
{
	loginfo "enable_switcher"
	if [ -d /newrootR ];then
		pushd /newrootR/opt/tvu/R/iMatrix;
		chmod a+x switcher;
		popd;
	else
		 pushd /opt/tvu/R/iMatrix;
		chmod a+x switcher;
		popd;
	fi
}

function enable_speechservice()
{
	echo "=======================";
	loginfo "enable_speechService"
	echo "========================"
	
	# echo "=========start install nfs=========="
	# apt install -y nfs-kernel-server nfs-common
	# echo "=========nfs install finish========="

	# systemctl enable nfs-kernel-server
	# systemctl restart nfs-kernel-server
	
	systemctl daemon-reload;
	# systemctl restart tvu.speech;
	
	if [ -d /newrootR ];then
		rm -rf /newrootR/etc/systemd/system/multi-user.target.wants/tvu.speech.service
		sed -i 's/systemctl restart tvu.speech.service/#systemctl restart tvu.speech.service/g' /newrootR/opt/tvu/modules/startup/linuxr/run.sh
		ln -s /etc/systemd/system/tvu.syncserver.service /newrootR/etc/systemd/system/multi-user.target.wants/tvu.syncserver.service
		chmod a+x /newrootR/opt/tvu/R/iMatrix/facerecognition/start.sh;
	else
		systemctl enable tvu.syncserver;
		systemctl stop tvu.speech;
		systemctl disable tvu.speech;
		sed -i 's/systemctl restart tvu.speech.service/#systemctl restart tvu.speech.service/g' /opt/tvu/modules/startup/linuxr/run.sh
		chmod a+x /opt/tvu/R/iMatrix/facerecognition/start.sh;
	fi
	
	systemctl restart tvu.syncserver;
}

function enable_grpcproxy(){
	echo "======================"
	loginfo "enable_grpcproxyService"
	echo "======================"

	
	if [ -d /newrootR ];then
		ln -s /etc/systemd/system/tvu.grpcproxy.service /newrootR/etc/systemd/system/multi-user.target.wants/tvu.grpcproxy.service
		chmod a+x /newrootR/opt/tvu/grpcproxy/proxy_start.sh
	else
		chmod a+x /opt/tvu/grpcproxy/proxy_start.sh
		systemctl enable tvu.grpcproxy.service;
	fi
	
	systemctl restart tvu.grpcproxy.service;
}
function enable_resourceservice()
{
	echo "============================="
	loginfo "enable_goresourceservice"
	echo "============================="
	
	if [ -d /newrootR ];then
		pushd /newrootR/opt/tvu/
		rm -rf /newrootR/opt/tvu/resource-service.1.*;
		tar -zxvf resource-service.tar.gz; 
		popd;
		pushd /newrootR/opt/tvu/resource-service.*/;
		chmod a+x install.sh;
		./install.sh -t $TARGET;
		popd;
		
		rm /newrootR/opt/tvu/resource-service.tar.gz -f
	else
		pushd /opt/tvu/
		rm -rf resource-service.1.*;
		tar -zxvf resource-service.tar.gz; 
		pushd /opt/tvu/resource-service.*/;
		chmod a+x install.sh;
		./install.sh -t $TARGET;
		popd;
		
		rm /opt/tvu/resource-service.tar.gz -f
		popd;
	fi
}
function enable_aiproxy()
{
if [ -d /newrootR ];then
	pushd /newrootR/opt/tvu/R/iMatrix;
	chmod a+x aiproxy;
	chmod a+x switcher;
	chmod a+x playeroftvu;
	popd;
else
    pushd /opt/tvu/R/iMatrix;
	chmod a+x aiproxy;
	chmod a+x switcher;
	chmod a+x playeroftvu;
	popd;
fi
}

function enable_faceCongService()
{
	loginfo "enable_faceCongService"
    systemctl stop tvu.localfacerecongnition.service
    systemctl disable tvu.localfacerecongnition.service
	
	if [ -d /newrootR ];then
		ln -s /etc/systemd/system/tvu.localface.service /newrootR/etc/systemd/system/multi-user.target.wants/tvu.localface.service
		if [ -f "/newrootR/etc/systemd/system/tvu.localfacerecongnition.service" ];then
			rm -rf /newrootR/etc/systemd/system/tvu.localfacerecongnition.service;
		fi
	else
		systemctl enable  tvu.localface.service;
		if [ -f "/etc/systemd/system/tvu.localfacerecongnition.service" ];then
			rm -rf /etc/systemd/system/tvu.localfacerecongnition.service;
		fi
	fi
	
	systemctl restart tvu.localface.service;
}

function enable_ftpupload()
{
	loginfo "enable_ftpupload"
	if [ -d /newrootR ];then
		ln -s /etc/systemd/system/tvu.ftpupload.service /newrootR/etc/systemd/system/multi-user.target.wants/tvu.ftpupload.service
	else
		systemctl enable tvu.ftpupload.service
	fi
	systemctl restart tvu.ftpupload.service
	loginfo "enable_ftpupload end"
}

function enable_upgradekey()
{
	loginfo "enable_upgradekey"
	if [ -d /newrootR ];then
		chmod a+x /newrootR/etc/cron.daily/upgradekey.sh;
	else
		chmod a+x /etc/cron.daily/upgradekey.sh;
	fi
	loginfo "enable_upgradekey end"
}

function enable_logodetector()
{
	loginfo "enable_logodetector"
	if [ -d /newrootR ];then
		chmod a+x /newrootR/opt/tvu/R/logodetector;
	else
		chmod a+x /opt/tvu/R/logodetector;
	fi
	loginfo "enable_logodetector end"
}

function enable_printpeerid()
{
	loginfo "enable_printpeerid"
	if [ -d /newrootR ];then
		chmod a+x /newrootR/opt/tvu/R/LinuxR_PrintPeerID.py;
	else
		chmod a+x /opt/tvu/R/LinuxR_PrintPeerID.py;
	fi
	loginfo "enable_printpeerid end"
}

function enable_R()
{
	if [ ! -d /newrootR ];then
		pushd /opt/tvu/R
		sed -i "s/^log4cplus.appender.fecAgent.Appender.MaxBackupIndex=.*/log4cplus.appender.fecAgent.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.libcore.Appender.MaxBackupIndex=.*/log4cplus.appender.libcore.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.file.Appender.MaxBackupIndex=.*/log4cplus.appender.file.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.live.Appender.MaxBackupIndex=.*/log4cplus.appender.live.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.playport.Appender.MaxBackupIndex=.*/log4cplus.appender.playport.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.ps.Appender.MaxBackupIndex=.*/log4cplus.appender.ps.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.module.Appender.MaxBackupIndex=.*/log4cplus.appender.module.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.debug.Appender.MaxBackupIndex=.*/log4cplus.appender.debug.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.fecAgent.Appender.MaxBackupIndex=.*/log4cplus.appender.fecAgent.Appender.MaxBackupIndex=3/g" log4cplus.properties
		sed -i "s/^log4cplus.appender.fecClient.Appender.MaxBackupIndex=.*/log4cplus.appender.fecClient.Appender.MaxBackupIndex=3/g" log4cplus.properties
		
		sed -i "s/^log4cplus.appender.grpc.Appender.MaxBackupIndex=.*/log4cplus.appender.grpc.Appender.MaxBackupIndex=3/g"  log4cplus.libcoregrpc.properties
		sed -i "s/^log4cplus.appender.fecServer.MaxBackupIndex=.*/log4cplus.appender.fecServer.MaxBackupIndex=3/g"  log4cplus.fecServer.properties
		sed -i "s/^log4cplus.appender.blob.Appender.MaxBackupIndex=.*/log4cplus.appender.blob.Appender.MaxBackupIndex=3/g"  log4cplus.libblob.properties
		popd
		
		rm /home/tvu/MMAPATCH/etc -rf
		rm /home/tvu/MMAPATCH/home -rf
		rm /home/tvu/MMAPATCH/opt -rf
		rm /home/tvu/MMAPATCH/root -rf
		rm /home/tvu/MMAPATCH/tmp -rf
		rm /home/tvu/MMAPATCH/usr -rf
	fi
	
	rm /opt/gcc-5* -rf
}

function enbale_lua()
{
    loginfo "enbale_lua"
	if [ -d /newrootR ];then
		chmod a+x /newrootR/usr/bin/lua;
		chmod a+x /newrootR/usr/bin/luac;
	else
		chmod a+x /usr/bin/lua;
		chmod a+x /usr/bin/luac;
	fi
	loginfo "enbale_lua end"
}

function change_file_usrgrp()
{
    loginfo "change_file_usrgrp"
	if [ -d /newrootR ];then
		chgrp tvu_op /newrootR/home/tvu_op/.config/*
		chown tvu_op /newrootR/home/tvu_op/.config/*
		chgrp tvu_op /newrootR/home/tvu_op/.config/autostart/*
		chown tvu_op /newrootR/home/tvu_op/.config/autostart/*
		chown tvu_op /newrootR/home/tvu_op/Desktop/*
		chgrp tvu_op /newrootR/home/tvu_op/Desktop/*
		chgrp tvu_op /newrootR/home/tvu_op/.config/pulse/*
		chown tvu_op /newrootR/home/tvu_op/.config/pulse/*
		chgrp tvu /newrootR/home/tvu/.config/pulse/*
		chown tvu /newrootR/home/tvu/.config/pulse/*
		chgrp tvu /newrootR/home/tvu
		chown tvu /newrootR/home/tvu
		chgrp root /newrootR/etc
		chown root /newrootR/etc
	else
		chgrp tvu_op /home/tvu_op/.config/*
		chown tvu_op /home/tvu_op/.config/*
		chgrp tvu_op /home/tvu_op/.config/autostart/*
		chown tvu_op /home/tvu_op/.config/autostart/*
		chown tvu_op /home/tvu_op/Desktop/*
		chgrp tvu_op /home/tvu_op/Desktop/*
		chgrp tvu_op /home/tvu_op/.config/pulse/*
		chown tvu_op /home/tvu_op/.config/pulse/*
		chgrp tvu /home/tvu/.config/pulse/*
		chown tvu /home/tvu/.config/pulse/*
		chgrp tvu /home/tvu
		chown tvu /home/tvu
		chgrp root /etc
		chown root /etc
	fi
	loginfo "change_file_usrgrp end"
}

function set_openresty_conf()
{
    pushd /opt/tvu/R
    loginfo "set_openresty_conf"
	PEER_ID=`python /opt/tvu/R/LinuxR_PrintPeerID.py | tail -n 1 | awk '{print substr($1,3,18)}'`
	hashvalue=$(echo -n "$PEER_ID"T1279 | md5sum)
    hashresult=${hashvalue:0:32}
	if [ -d /newrootR ];then
		sed -i 's/MMAR1/'$PEER_ID'/g' /newrootR/etc/nginx/conf.d/transceiver.conf
		sed -i 's/MMAMD5R1/'$hashresult'/g' /newrootR/etc/nginx/conf.d/transceiver.conf
	else
		sed -i 's/MMAR1/'$PEER_ID'/g' /etc/nginx/conf.d/transceiver.conf
		sed -i 's/MMAMD5R1/'$hashresult'/g' /etc/nginx/conf.d/transceiver.conf
	fi
	loginfo "set_openresty_conf end"
	popd
}

_main()
{
	loginfo "newrun.sh -r rVerison -m mmaVersion -e test/china/global/null -t dev/test/prod"
	
	while getopts "r:m:e:t:a:" arg
	do
		case $arg in
			r)
				loginfo "update R version $OPTARG"
				R_VERSION=$OPTARG
				;;
			m)
				loginfo "mma version $OPTARG"
				MMA_VERSION=$OPTARG
				;;
			e)
				loginfo "environment $OPTARG"
				ENVIRONMENT=$OPTARG
				;;
			t)
				loginfo "target $OPTARG"
				TARGET=$OPTARG
				;;
			?)
				loginfo "unkonw argument"
				exit -1
				;;
		esac
	done
	
	disable_nginx
	patch_mma
	enable_openresty
	create_mp4tmp
	#change_host 不执行了
	enable_tvu264
	enable_speechservice
	enable_resourceservice
	#enable_faceCongService
	enable_grpcproxy
	enable_aiproxy
	enable_ftpupload
	enable_upgradekey
	enable_logodetector
	enable_printpeerid
	enable_R
	enbale_lua
	change_file_usrgrp
	set_openresty_conf
    systemctl restart tvu.ftpupload.service
    systemctl restart tvu.setting3a.service
    systemctl restart tvu.thumbnailupload.service
	systemctl restart tvu.r.service
    systemctl restart sshd
	loginfo "===================Apply mma patch $MMA_VERSION done========================="
}

_main $@
