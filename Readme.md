# OpenFF

Industry: Molecular Dynamics, drug discovery, fundamental science

Target OS: Linux

License: Open Source

Website: https://openforcefield.org/

Github: https://github.com/openforcefield

Notes: There are two primary components: 1. the server (qcfractal-server) 2. and the worker. The server must be exposed on port 7777 on a network reachable by the worker. Both can be distrubuted as conda packages. 

run the server like this: docker run -d -p 7777:7777 qcserver

run the worker like this: docker run --rm qcworker


docker network create galileo-net

docker run -d -p 7777:7777 --network galileo-net --name qcserver qcserver

docker run -d -p 4040:4040 --network galileo-net --name ngrok wernight/ngrok

docker container exec ngrok curl -i -X GET 127.0.0.1:4040/api/tunnels

docker container exec ngrok curl -i -X DELETE 127.0.0.1:4040/api/tunnels/<name of tunnel>
  
docker container exec ngrok curl -i -X POST -H "Content-Type: application/json" --data "{\"addr\":\"qcserver:7777\",\"proto\":\"http\",\"name\":\"openff\"}" 127.0.0.1:4040/api/tunnels
