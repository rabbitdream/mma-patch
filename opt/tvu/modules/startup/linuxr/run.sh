#!/bin/bash
# filename: run.sh
# purpose:  startup logic of linuxr only.
# author:   Evan Li moved from /root/receiver.sh on 05/16 2022

MYDIR=`dirname $0`
pushd $MYDIR

IMG_PATH="/opt/tvu/config/manifest-lr-update.json"
CONTAINER_PATH="/opt/tvu/config/manifest-lr-boot.json"

# 0 exist
# 1 not
function is_docker_image_exist(){
    image_tag=$1
    docker image inspect $image_tag > /dev/null
    return $?
}

function load_images(){
    echo "[$(date)] loading images..."
    count=$(jq -r '.DckPackages|length' $IMG_PATH)

    for((i=0;i<$count;i++))
    do
        tag=$(jq -r ".DckPackages[$i].Tag" $IMG_PATH)
        repo=$(jq -r ".DckPackages[$i].Repository" $IMG_PATH)
        echo "[INFO] checking image $repo:$tag..."
        is_docker_image_exist $repo:$tag
        code=$?
        if [[ $code != 0 ]]; then
            echo "Warn : image $repo:$tag does not exist."
            path=$(jq -r ".DckPackages[$i].Path" $IMG_PATH)
            image_tar="/data/${path##*/}"
            if [ -f $image_tar ]; then
                echo "[INFO] try to load $repo:$tag from $image_tar..."
                docker load -i $image_tar
                if [ $? -eq 0 ]; then
                    echo "[INFO] load $image_tar successed."
                    rm -rf $image_tar
                else
                    echo "[ERROR] load $image_tar failed!"
                fi
            else
                echo "[ERROR] missing file $image_tar."
            fi
        else
            echo "[INFO] image $repo:$tag exist."
        fi
    done
    echo "[$(date)] images loaded."
}

function load_containers(){
    echo "[$(date)] loading containers..."
    count=$(jq '.|length' $CONTAINER_PATH)
    images_count=$(jq -r '.DckPackages|length' $IMG_PATH)

    for((i=0;i<$count;i++))
    do
        img=$(jq -r ".[$i].Image" $CONTAINER_PATH)
        for((j=0;j<$images_count;j++))
        do
            if [ $(jq -r ".DckPackages[$j].Name" $IMG_PATH) = $img ]; then
                tag=$(jq -r ".DckPackages[$j].Tag" $IMG_PATH)
                repo=$(jq -r ".DckPackages[$j].Repository" $IMG_PATH)
                name=$(jq -r ".[$i].Name" $CONTAINER_PATH)
                cmd=$(jq -r ".[$i].Command" $CONTAINER_PATH)

                is_docker_image_exist $img:$tag
                code=$?
                if [[ $code == 0 ]]; then
                    if [ ! "$(docker ps -q -f name=$name)" ]; then
                        echo "[INFO] start container $name $repo:$tag..."
                        docker run -d --name $name $cmd $repo:$tag
                    else
                        echo "[INFO] container $name $repo:$tag already exist."
                    fi
                    if [ $? -eq 0 ]; then
                        echo "[INFO]  start container $name succeed."
                    else
                        echo "[ERROR] start container $name failed!"
                    fi
                else
                    echo "[ERROR] missing image $repo:$tag"
                fi
                break
            fi
        done
    done
    echo "[$(date)] containers loaded."
}

function load_peerclient(){
    echo "[$(date)] loading peerclient..."
    #for peerclient
    peerclinetversion=$(jq -r '.docker.peerclient' /opt/tvu/R/Variants/Receiver/modulelist.json)  
    is_docker_image_exist docker.tvunetworks.com/tvurtc/peerclient:${peerclinetversion}
    peerclient_code=$?
    if [[ $peerclient_code != 0 ]]; then
        echo "[INFO] image peeclient does not exist."
        peerclient_image_tar="/data/peerclient_${peerclinetversion}.tar"
        if [ ! -d $peerclient_image_tar ]; then
            echo "[INFO] loading peerclient from $peerclient_image_tar"
            docker load -i $peerclient_image_tar
            rm -rf $peerclient_image_tar
        else
            echo "[ERROR] missing file $peerclient_image_tar"
        fi
    else
        echo "[INFO] peerclient ${peerclinetversion} exist."
    fi
    echo "[$(date)] peerclient loaded."
}

function run_level_1(){
    #Evan said this expired.
    #dotnet /opt/tvu/R/TVU.App.PrepareLinuxREnvironment.dll

    echo "start nginx"
    systemctl restart nginx

    echo "start transceiver.daemon.service"
    systemctl restart transceiver.daemon.service

    echo "start tvu.auth.service"
    systemctl restart tvu.auth.service

    echo "start tvu.portest.service"
    python sync_inbound_ports_to_portest.py
    systemctl restart tvu.portest.service

    echo "start tvu.s3transfer.service"
    systemctl restart tvu.s3transfer.service

    echo "start tvu.thumbnailupload.service"
    systemctl restart tvu.thumbnailupload.service

    echo "start tvu.grpcproxy.service"
    systemctl restart tvu.grpcproxy.service

    #echo "start tvu.speech.service"
    #systemctl restart tvu.speech.service
}

function run_level_2(){
    load_images
	echo "run script update MMA"
    bash /usr/sbin/updateTrack > /var/log/update_mma.log
    load_containers
    load_peerclient

    echo "[$(date)] tick tick."
    count=0
    while true
    do
        curl -o /dev/null -s http://127.0.0.1:15672
        if [ $? -ne 0 ]; then
            if [ $count -lt 60 ]; then
                echo "[$(date)]: connect to rabbitmq fail."
                sleep 2s
            else
                echo "[$(date)]: start rabbitmq container fail." 
                break
            fi
            
        else
            echo "[$(date)]: connect to rabbitmq success."
            break
        fi
        count=$(($count+1))
    done

    echo "[$(date)] start tvu.setting3a.service"
    systemctl restart tvu.setting3a.service

    echo "[$(date)] start tvu.ftpupload.service"
    systemctl restart tvu.ftpupload.service

    echo "[$(date)] start tvu.sysmonitor.service"
    systemctl restart tvu.sysmonitor.service

    echo "[$(date)] start tvu.chronyp.service"
    systemctl restart tvu.chronyp.service

    echo "[$(date)] start tvu.thumbnailcreator.service"
    systemctl restart tvu.thumbnailcreator.service

    while read line
    do
        if [ ! $line == "" ]; then
            echo "[$(date)] start $line"
            systemctl restart $line
        fi
    done < "./startup.conf"
}

level=${1-1}
case $level in
    1)
        run_level_1
    ;;
    2)
        run_level_2
    ;;
esac

popd
