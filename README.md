<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/ethminer/ethereum.png" width="225">
</p>

# ETHMINER

## Overview
- **Industry**: Cryptocurrency, Ethereum

- **Target Conatiner OS**: Linux

- **Source Code**: open source

- **Website**: https://www.ethermine.org;

- **Github**: https://github.com/ethereum-mining/ethminer

## Notes
This is a cryptocurrency miner designed to mine ETH (Ethereum). Specifically, it targets Nvidia GPU platforms. It will not work for CPU mining. 

## Building

This container runtime is targeted for linux machines (with an NVIDIA GPU that has at least 4GB of available RAM).

To build, run:

```
docker build -t ethminer .
```

## Running
Environment varaibles:

1. SCHEME
	- Options:
		- http
		- stratum+tcp
		- stratum1+tcp
		- stratum2+tcp

2. WALLET
	Options:
		- must be a valid Etherum wallet address
		
3. WORKERNAME
	- Options:
		- alphanumerical name (i.e. bigIron)

4. PASSWORD
	- Options:
		- this is optional, usually not required for most mining pools

5. POOLNAME
	- Options:
		- eu1.ethermine.org:4444 stratum
		- asia1.ethermine.org:4444, stratum
		- us1.ethermine.org:4444, stratum (east)
		- us2.ethermine.org:4444, stratum (west)

6. PORT
	- Options:
		- see pool for port specification

The entrypoint of the container is of the form:
```
ethminer -U --pool stratum+tcp://0xf12dEe43BBB573aD5fF4f0Dc773fE3e729e0a95B.bigIron@us2.ethermine.org:4444
```

When running the container, be sure to mount a GPU: 

```
docker run -d --rm --gpus all -e WALLET XXX -e WORKERNAME BigIron -e POOLNAME us2.ethrmine.org -e PORT 4444 ethminer
```
