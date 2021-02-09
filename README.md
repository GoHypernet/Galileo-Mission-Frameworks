# XMRIG

## Overview
- **Industry**: Cryptocurrency, Monero

- **Target Container OS**: Linux

- **Source Code**: open source

- **Github**: https://github.com/xmrig/xmrig

## Notes

This is a cryptocurrency miner specifically designed to mine XMR (Monero). It works both for CPU and GPU mining, 
however, GPU mining is very inefficient due to the nature of the underlying [RandomX](https://github.com/tevador/RandomX) mining protocol. 
 
## Building

This container runtime is targeted at linux. To build the container run:

```
docker build -t xmrig .
```

## Running
Environment varaibles:

1. DONATE_LVL
	- Options (default value is 1):
		- integer from 1 to 100 (percent)

2. WALLET
	Options:
		- must be a valid Monero wallet address to work
		
3. RIG_ID
	- Options:
		- alphanumerical name with no spaces (i.e. bigIron)

5. POOL
	- Options (you can use any valid mining pool, this is just a short list):
		- us-west.minexmr.com (port 443)
		- ca.minexmr.com (port 443)
		- pool.minexmr.com (port 443)
		- sg.minexmr.com: (port 443)
    - fr.minexmr.com (port 443)

6. PORT
	- Options:
		- see pool for port specification

```
docker run -d --rm -e WALLET 4XXX -e RIG_ID bigiron -e POOL us-west.minexmr.com -e PORT 443 xmrig
```
