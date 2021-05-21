<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/harmony/harmony-one-logo.png" width="200">
</p>

# Harmony

## Overview
- **Industry**: Cryptocurrency, node hosting

- **Target Container OS**: Linux

- **Source Code**: open source

- **Github**: https://github.com/harmony-one

## Notes

Harmony is a Proof-of-Stake protocol. This branch couples the Galileo IDE with the official Harmony binary release. 

This environment includes python and go runtimes.

This containerized application exposes the following reverse proxy endpoints:

- /rpc/* -> locoalhost:9500 (remote procedure call)
- /ws/* -> localhost:9800 (websockets)
- /metrics/* -> localhost:9900 (dedicated metrics endpoint)
 

## Building

This container runtime is targeted at linux. To build the container run:

```
docker build -t harmony .
```