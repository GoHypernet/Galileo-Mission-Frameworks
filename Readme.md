# OpenFF

Industry: Molecular Dynamics

Target OS: Linux

License: Open Source

Website: https://openforcefield.org/

Github: https://github.com/openforcefield

Notes: There are two primary components: 1. the server (qcfractal-server) 2. and the worker. The server must be exposed on port 7777 on a network reachable by the worker. Both can be distrubuted as conda packages. 

run the server like this: docker run -d -p 7777:7777 qcserver
run the worker like this: docker run --rm qcworker
