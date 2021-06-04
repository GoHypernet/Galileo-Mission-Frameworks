<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/Terra/terra_logo.png" width="200">
</p>

# Terra Core

## Overview
- **Industry**: Cryptocurrency, node hosting

- **Target Container OS**: Linux

- **Source Code**: open source

- **Github**: https://github.com/terra-money/core

## Notes

Terra Core is the reference implementation of the Terra protocol, written in Golang. Terra Core is built atop Cosmos SDK and uses Tendermint BFT consensus. If you intend to work on Terra Core source, it is recommended that you familiarize yourself with the concepts in those projects.

	handle_path /p2p/* {
        reverse_proxy http://localhost:26656
    }
	
	handle_path /RPC/* {
        reverse_proxy http://localhost:26657
    }
	
	handle_path /LCD/* {
        reverse_proxy http://localhost:1317
    }
    
	handle_path /prometheus/* {
        reverse_proxy http://localhost:26660
		import /tmp/hashpass.txt
    }

- /p2p/* -> locoalhost:26656 (p2p connection port)
- /RPC/* -> localhost:26657 (Remost Procedure Call API)
- /LCD/* -> localhost:1317 (Lite Client Daemon API)
 

## Building

This container runtime is targeted at linux. To build the container run:

```
docker build -t terra .
```