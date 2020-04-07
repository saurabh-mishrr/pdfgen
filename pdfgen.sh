#!/bin/bash

nginx_path=$(pwd)/nginx/nginx.conf
nginx_dockerfile=$(pwd)/nginx/Dockerfile
gunicorn_dockerfile=$(pwd)/Dockerfile
python_src=$(pwd)/src
web_image_name="cactushub/pdf_generator_web:latest"
web_docker_name="local.pdf.gen"
api_image_name="cactushub/pdf_generator_api:latest"
api_docker_name="local.pdfgen.api"
network_name="pdf_gen_network"
export PYTHONSRC=${python_src}

function create_all_services() {
    echo "Hello, we are going to create all services"


    echo "Creating Network, ${network_name}"
    docker network create --driver bridge --subnet 172.19.0.0/16 ${network_name}

    echo "Creating Image, ${api_image_name}"
    docker build -f ${gunicorn_dockerfile} --force-rm --no-cache -t ${api_image_name} .
    echo "Running Docker, ${api_docker_name}"
    docker run \
        -d \
        --expose 5000 \
        -it \
        --ip 172.19.0.3 \
        --name ${api_docker_name} \
        --network ${network_name} \
        -p 5000:5000 \
        --restart always \
        -v ${python_src}:/code:rw \
        ${api_image_name} \
        gunicorn -b 0.0.0.0:5000 app --reload


    echo "Creating Image, ${web_image_name}"
    docker build -f ${nginx_dockerfile} --force-rm --no-cache -t ${web_image_name} .
    echo "Running Docker, ${web_image_name}"
    docker run \
        --expose 80 \
        -it \
        --hostname ${web_docker_name} \
        --ip 172.19.0.4 \
        --name ${web_docker_name} \
        --network ${network_name} \
        -p 5001:80 \
        -v ${nginx_path}:/etc/nginx/nginx.conf:ro \
        -d ${web_image_name}

    # --mount type=bind,src=${nginx_path},dst=/etc/nginx/nginx.conf \
}

function start_all_services() {
    echo "Starting ${web_docker_name}"
    docker start ${web_docker_name}
    echo "Starting ${api_docker_name}"
    docker start ${api_docker_name}
}

function stop_all_services() {
    echo "Stoping ${web_docker_name}"
    docker stop ${web_docker_name}
    echo "Stoping ${api_docker_name}"
    docker stop ${api_docker_name}
}

function remove_all_servives() {
    stop_all_services
    echo "Removing ${web_docker_name}"
    docker rm ${web_docker_name}
    echo "Removing ${api_docker_name}"
    docker rm ${api_docker_name}
    echo "Removing ${web_image_name}"
    docker rmi ${web_image_name} -f
    echo "Removing ${api_image_name}"
    docker rmi ${api_image_name} -f
    echo "Removing network, ${network_name}"
    docker network rm ${network_name}
}

if [[ $1 == create ]];
then
    create_all_services

elif [[ $1 == start ]];
then
    start_all_services

elif [[ $1 == stop ]];
then
    stop_all_services

elif [[ $1 == rm ]];
then
    remove_all_servives

else
    echo "Kindly, use bash pdfgen.sh with following options create,start,stop or rm option"
    echo "e.g."
    echo "bash ./pdfgen.sh create"
    echo "It should be in order to create, start, stop and remove if want"
    echo "Create will run once only"
fi




