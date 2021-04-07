# Readme

This repo provides scripts to build and run vector single container. The plan is to migrate one component at a time. Included components:
- Vector node
- Vector router
- Redis cache server
- Vector Dashboard
- Nats server
- Auth server
- HAProxy server

## Not yet included
- Local etherium provider node. Currently uses external eth provider node deployed at https://chain.k8s.lax-hamrostack.com
- Postgres server(currently uses SQLite)

## Current status
Build works successfully. All the containers start successfully.

## Caveats
- ~~I'm currently using default eth provider from connext(Docker image: connextproject/vector_ethprovider:0.2.0-beta.7). However, when deployed, router can't get eth provider info in metrics path. Ethprovider 1337 is not being registered properly. As a result, even the dasboard doesn't work properly. Dashboard was successfully deployed using upstream docker images [here](https://router.k8s.lax-hamrostack.com/dashboard/) [Error at](https://github.com/GoHypernet/vector/blob/9820aab8c0b55096967e7567cdd9ba15794ef6f3/modules/router/src/metrics.ts#L88)~~. Fixed by removing our custom chain. Will need to look at it again to see where things went wrong.
```
{"level":50,"time":1616758210830,"pid":560,"hostname":"5f911bc6e1e7","name":"vector8AXWmo3dFpK1drnjeWPyi9KTy9Fy3SkCydWx8waQrxhnW4KPmR","reqId":2,"req":{"method":"GET","url":"/metrics","hostname":"localhost:8000","remoteAddress":"127.0.0.1","remotePort":47510},"res":{"statusCode":500},"err":{"type":"TypeError","message":"Cannot read property 'name' of undefined","stack":"TypeError: Cannot read property 'name' of undefined\n    at Promise.all.Object.entries.map (webpack:///./src/metrics.ts?:64:45)\n    at process._tickCallback (internal/process/next_tick.js:68:7)"},"msg":"Cannot read property 'name' of undefined"}
```

## Getting started
```
# Set version name
export VERSION=$(date +%F)
Change IMAGE variable in vector-container/build.sh to update the target image name.
# default value is
IMAGE=hamropatrorepo/vector

# Build the container. 
make build

# Port 80 for the proxy to router, node, dashboard, etc. 8000 to access the router directly
make run

```

## Environment variables (non-exhaustive)
- NODE_ENV
- VECTOR_PROD
- VECTOR_ENV
- VECTOR_JWT_SIGNER_PRIVATE_KEY
- VECTOR_MNEMONIC
- VECTOR_NATS_URL
- VECTOR_ADMIN_TOKEN
- VECTOR_PORT

