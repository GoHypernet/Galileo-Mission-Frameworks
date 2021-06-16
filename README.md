<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/connext/connext_logo.png" width="200">
</p>

# Algorand

## Overview
- **Industry**: Cryptocurrency, Layer 2 Scaling

- **Target Container OS**: Linux

- **Source Code**: open source

- **Github**: https://github.com/connext/

## Notes

Connext is a Layer 2 scaling technology based on the concept of state channels. It is designed to work with 
EVM-based smart contract platforms. 


## Building

This container runtime is targeted at linux. To build the container run:

```
docker build -t vector_node .
```

## Running

```
docker run -d -p 8888:8888 --rm --name vector_node vector_node .
```