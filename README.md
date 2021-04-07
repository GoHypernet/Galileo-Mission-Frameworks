# Readme

This repo provides scripts to build and run vector single container. The plan is to migrate one component at a time. Included components:
- Vector node
- Vector router
- Redis cache server
- Vector Dashboard
- Nats server (to be removed. Part of auth server.)
- Auth server (to be removed)
- HAProxy server (to be removed. Part of auth server.)

## Current status
Build works successfully. All the containers start successfully.

## Caveats
- ~~I'm currently using default eth provider from connext(Docker image: connextproject/vector_ethprovider:0.2.0-beta.7). However, when deployed, router can't get eth provider info in metrics path. Ethprovider 1337 is not being registered properly. As a result, even the dasboard doesn't work properly. Dashboard was successfully deployed using upstream docker images [here](https://router.k8s.lax-hamrostack.com/dashboard/) [Error at](https://github.com/GoHypernet/vector/blob/9820aab8c0b55096967e7567cdd9ba15794ef6f3/modules/router/src/metrics.ts#L88)~~. Fixed by removing our custom chain. Will need to look at it again to see where things went wrong.
```
{"level":50,"time":1616758210830,"pid":560,"hostname":"5f911bc6e1e7","name":"vector8AXWmo3dFpK1drnjeWPyi9KTy9Fy3SkCydWx8waQrxhnW4KPmR","reqId":2,"req":{"method":"GET","url":"/metrics","hostname":"localhost:8000","remoteAddress":"127.0.0.1","remotePort":47510},"res":{"statusCode":500},"err":{"type":"TypeError","message":"Cannot read property 'name' of undefined","stack":"TypeError: Cannot read property 'name' of undefined\n    at Promise.all.Object.entries.map (webpack:///./src/metrics.ts?:64:45)\n    at process._tickCallback (internal/process/next_tick.js:68:7)"},"msg":"Cannot read property 'name' of undefined"}
```

## Getting started
```
# Set repo and version. Or leave it to set default
export REPO=vector/single
export VERSION=latest

# Build the container. 
make build

# Uses REPO and VERSION from above and exposes port 8080 for local testing. 
make run

```

## Ports
- 8080 for the nginx proxy that routes to the dashboard, node and router. You need to make this available to the external services to access the router and dashboard.
   - /node - node
   - /router - router
   - /dashboard/ - dashboard
- 8000 for router. Proxied via 8080 and no need to expose to outside world.
- 8001 for node. Works similar to router.
- 3000 for dashboard. Works similar to router.
- 80 for auth proxy. This can be disabled via supervisord.conf.template. Currently embedded inside the image. Ideally, this will be an external service to be consumed by router and node.

## Security
For rebalance, the adminToken is given via the environment variable ``ADMIN_TOKEN``. The dasboard itself is secured via Basic Authentication(not the best security method out there but gets the job done for this demo).
Default username and password are ``root`` and ``password`` respectively.

## Environment variables (non-exhaustive)
See build.sh for exhaustive list of environment variables(search for ``ENV`` tags in dockerfile). All of the environment variables have sane defaults for development. Don't use it in production without proper security audit/testing.
- NODE_ENV
- VECTOR_PROD
- VECTOR_ENV
- VECTOR_JWT_SIGNER_PRIVATE_KEY
- VECTOR_MNEMONIC
- VECTOR_NATS_URL
- VECTOR_ADMIN_TOKEN
- VECTOR_PORT
- ROUTER_HOST
- DASHBOARD_HOST
- NODE_HOST
- ADMIN_TOKEN 
- METRICS_URL
- AUTO_REBALANCE_URL

## Configuration
Along with updating the environment variables, you might need to update the vector-config.json file. You can mount the configuration file at ``/root/vector-config.json`` and it will be picked up by the container.

The file can be mounted as volume in docker stack and as configMap volume mount in k8s.

