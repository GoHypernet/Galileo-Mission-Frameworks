<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/algorand/algorand_logo.png" width="200">
</p>

# Galileo-Algorand Environment

## Overview
- **Industry**: Cryptocurrency, node hosting

- **Target Container OS**: Linux

- **Source Code**: open source

- **Github**: https://github.com/algorand/

## Notes

Algorand is a Proof-of-Stake protocol. This branch couples the Galileo IDE with the official Algorand stable docker image. 

Running a relay node requires syncing the full blockchain, which as of 5-12-2021 requires 490GB of disk space. 

This containerized application exposes the following reverse proxy endpoints:

- /* -> localhost:4161 (Relay node connections)
- /ui/* -> localhost:3000 (Galileo IDE + authentication)
- /rclone/* -> localhost:5572 (rclone api)
- /rpc/* -> localhost:8080 (Algod rest API)
 
Additionally, the runtime environment contains node and python 3.8 for Algorand Smart Contract development. 

## Building

This container runtime is targeted at linux. To build the container run:

```
docker build -t algorand .
```