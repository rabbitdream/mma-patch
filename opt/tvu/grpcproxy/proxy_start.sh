#!/bin/bash
httpaddr=$1
httpsaddr=$2
remote_addr_config_file=$3
default_remote_addr=$4
protofile=$5
cerfile=""


#cd  /opt/tvu/grpcproxy/grpcproxy
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
cd ${SHELL_FOLDER}
function jsonValue() {
KEY=$1
num=$2
awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

addr=`cat ${remote_addr_config_file} |grep metadatadgrpc |cut -d '"' -f 4|sed 's/"//g' |sed 's/,//g'`
headvalue_1=`cat ${remote_addr_config_file} |grep tagvalue |cut -d '"' -f 4|sed 's/"//g' |sed 's/,//g'`

if [ "${addr}" = "" ];then
    echo "configure file error,use default addr"
    addr=${default_remote_addr}
fi

if [ "${headvalue_1}" = "test" ];then
    echo "headvalue_1 is test,so cer"
    cerfile="server.pem"
fi

echo addr=${addr}

# /opt/tvu/grpcproxy/grpcproxy 127.0.0.1:5005 127.0.0.1:5006 m1.tvunetworks.com:8570 metadataproto.proto

# /opt/tvu/grpcproxy/grpcproxy ${httpaddr} ${httpsaddr} ${addr} ${protofile}
/opt/tvu/grpcproxy/grpcproxy --listenaddr=${httpaddr}  --listenaddr_s=${httpsaddr} --remoteaddr=${addr}  --protofile=${protofile}  --headkey_1=tagvalue  --headvalue_1=${headvalue_1}  --cerfile=${cerfile}
