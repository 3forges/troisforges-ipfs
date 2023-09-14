## Run it

* git clone and :

```bash
export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
docker-compose build --build-arg KUBO_VERSION=latest kubo_build
docker-compose up -d
```

## API Authencitation of the webui

* https://docs.ipfs.tech/reference/kubo/cli/#ipfs-config
* https://github.com/ipfs/kubo/blob/master/Dockerfile#L98 : `ENTRYPOINT`
* https://github.com/ipfs/kubo/blob/master/Dockerfile#L106 : `CMD`

* ccc : 

```bash

```
