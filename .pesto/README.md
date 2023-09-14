## Run it

* git clone and :

```bash
export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
docker-compose -f ./docker-compose.build.yml build \
               --build-arg KUBO_VERSION=latest \
               kubo_build
docker-compose up -d
```
* When the stack is up, we can already query the `ipfs/kubo` api :

```bash
$ curl -X POST -iv http://onedev.pokus.io:5001/api/v0/version | tail -n 1 | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 192.168.191.202:5001...
* Connected to onedev.pokus.io (192.168.191.202) port 5001 (#0)
> POST /api/v0/version HTTP/1.1
> Host: onedev.pokus.io:5001
> User-Agent: curl/7.77.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: nginx/1.19.2
< Date: Thu, 14 Sep 2023 21:27:51 GMT
< Content-Type: application/json
< Connection: close
< Access-Control-Allow-Headers: X-Stream-Output, X-Chunked-Output, X-Content-Length
< Access-Control-Expose-Headers: X-Stream-Output, X-Chunked-Output, X-Content-Length
< Trailer: X-Stream-Error
< Vary: Origin
<
{ [96 bytes data]
100    96    0    96    0     0   6466      0 --:--:-- --:--:-- --:--:--  8000
* Closing connection 0
{
  "Version": "0.22.0",
  "Commit": "3f884d3",
  "Repo": "14",
  "System": "amd64/linux",
  "Golang": "go1.19.10"
}


```

## TRoubleshooting

### API Authencitation of the webui

* https://docs.ipfs.tech/reference/kubo/cli/#ipfs-config
* https://github.com/ipfs/kubo/blob/master/Dockerfile#L98 : `ENTRYPOINT`
* https://github.com/ipfs/kubo/blob/master/Dockerfile#L106 : `CMD`

* ccc : 

```bash

```
