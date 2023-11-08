#!/bin/bash
# filename: run_docker_vision.sh
# author:   Ari.

visionport=${1:-noset}


function main(){
    echo ${visionport}
    docker rm -f lib_vision
    docker run -d --restart=always --net=host -m 2.5g --memory-swap 5g -v /dev/shm:/dev/shm -v /opt/tvu/config:/opt/tvu/config -v /opt/tvu/R/log:/opt/tvu/R/log -v /usr/share/nginx:/usr/share/nginx -v /opt/tvu/R/iMatrix/lib_vision_log.conf:/opt/tvu/R/iMatrix/lib_vision_log.conf -v /opt/tvu/R/iMatrix/vision.json:/opt/tvu/R/iMatrix/vision.json --name lib_vision lib_vision:latest /opt/tvu/R/iMatrix/vision_server 127.0.0.1:${visionport}
}

main
