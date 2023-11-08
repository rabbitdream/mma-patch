#! /bin/bash -----

if [ -d /newrootR ];then
	if [ ! -d "/newrootR/data/mp4tmp" ]; then
        sudo mkdir -p /newrootR/data/mp4tmp
        sudo chmod 777 /newrootR/data/mp4tmp
	fi
	if [ ! -d "/newrootR/data/mp4tmp/mem" ]; then  
		sudo mkdir -p /newrootR/data/mp4tmp/mem
		sudo chmod 777 /newrootR/data/mp4tmp/mem
	fi
	if [ ! -d "/newrootR/data/mp4tmp/mp4" ]; then
		sudo mkdir -p /newrootR/data/mp4tmp/mp4
		sudo chmod 777 /newrootR/data/mp4tmp/mp4
	fi
else
	if [ ! -d "/data/mp4tmp" ]; then
        sudo mkdir -p /data/mp4tmp
        sudo chmod 777 /data/mp4tmp
	fi
	if [ ! -d "/data/mp4tmp/mem" ]; then
		sudo mkdir -p /data/mp4tmp/mem
		sudo chmod 777 /data/mp4tmp/mem
	fi
	if [ ! -d "/data/mp4tmp/mp4" ]; then
		sudo mkdir -p /data/mp4tmp/mp4
		sudo chmod 777 /data/mp4tmp/mp4
	fi
fi










