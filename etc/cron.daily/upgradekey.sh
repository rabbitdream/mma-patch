wget --timeout=3 --waitretry=2 --tries=3  -O /tmp/server.crt http://gus.tvunetworks.com/update/LinuxR/data/MMA/server.crt
if [ ! -e /tmp/server.crt ]
then
    wget --timeout=3 --waitretry=2 --tries=3  -O /tmp/server.crt http://gus.tvunetworks.cn/update/LinuxR/data/MMA/server.crt
fi	
diffresult=$(diff /tmp/server.crt /usr/local/openresty/nginx/conf/server.crt)
echo ${diffresult}
if [ -n "${diffresult}" ]
then
    \cp -rf /tmp/server.crt /usr/local/openresty/nginx/conf/server.crt
	systemctl restart openresty
else
    echo "== do nothing"
fi

wget --timeout=3 --waitretry=2 --tries=3  -O /tmp/server.key http://gus.tvunetworks.com/update/LinuxR/data/MMA/server.key
if [ ! -e /tmp/server.key ]
then
    wget --timeout=3 --waitretry=2 --tries=3  -O /tmp/server.key http://gus.tvunetworks.cn/update/LinuxR/data/MMA/server.key
fi	
diffresult=$(diff /tmp/server.key /usr/local/openresty/nginx/conf/server.key)
echo ${diffresult}
if [ -n "${diffresult}" ]
then
    \cp -rf /tmp/server.key /usr/local/openresty/nginx/conf/server.key
	systemctl restart openresty
else
    echo "== do nothing"
fi
