#!/bin/sh

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start_ipfs"]

# chmod a+rw /data/ipfs/config
# chmod a+rw -R /data/ipfs/
chmod a+rw -R $IPFS_PATH
echo ''
echo ''
echo "Configuring CORS of IPFS/KUBO server"
echo ''
# ---
# https://docs.ipfs.tech/reference/kubo/cli/#ipfs-daemon
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://onedev.pokus.io:8080", "http://onedev.pokus.io:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["GET", "PATCH", "DELETE", "PUT", "POST"]'

# ---
# https://github.com/ipfs/kubo/blob/master/docs/config.md#gateway-recipes
# ipfs config --json Gateway.PublicGateways '["http://onedev.pokus.io:8080", "http://localhost:8080"]'
ipfs config --json Gateway.PublicGateways '{
    "onedev.pokus.io": {
        "UseSubdomains": false,
        "Paths": ["/ipfs", "/ipns", "/api"]
    }
}'
ipfs config --json Gateway.RootRedirect '/'
ipfs config --json Gateway.NoFetch false
ipfs config --json Gateway.NoDNSLink false
ipfs config --json Addresses.API "/ip4/onedev.pokus.io/tcp/5001"
ipfs config --json Addresses.Gateway "/ip4/onedev.pokus.io/tcp/8080"
# ipfs1         |   "Addresses": {
# ipfs1         |     "API": "/ip4/0.0.0.0/tcp/5001",
# ipfs1         |     "Announce": [],
# ipfs1         |     "AppendAnnounce": [],
# ipfs1         |     "Gateway": "/ip4/0.0.0.0/tcp/8080",

# ipfs config --json API.HTTPHeaders.X-Special-Header "[\"so special :)\"]"
# ipfs config --json Gateway.HTTPHeaders.X-Special-Header "[\"so special :)\"]"
echo ''
echo ' Checking IPFS config file'
echo " \$IPFS_PATH/config = [$IPFS_PATH/config]"
echo ''
echo '# ------------------------------------------------------ # '
echo ''
echo "Content of [$IPFS_PATH/config] of IPFS/KUBO server : "
echo ''
echo '# ------------------------------------------------------ # '
echo ''
echo ''
echo ' Checking IPFS config [ipfs config show]'
echo ''
ipfs config show
echo '# ------------------------------------------------------ # '

# --- 
# https://github.com/ipfs/kubo/blob/master/docs/environment-variables.md#ipfs_http_routers
# -
# export IPFS_HTTP_ROUTERS="http://0.0.0.0:8080" ipfs daemon
# ipfs config Routing.Type auto
# 
# export IPFS_HTTP_ROUTERS="http://0.0.0.0:8080"
# -----------------
# chmod a+rw /data/ipfs/config
# chmod a+rw -R /data/ipfs/
chmod a+rw -R $IPFS_PATH
ls -alh $IPFS_PATH/config

echo ''
echo ''
echo "Starting IPFS/KUBO "
echo ''
echo 'Script invocation passed arguments are :'
for var in "$@"
do
    echo "$var"
done
echo ''
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '
echo "  CONTENT OF [/usr/local/bin/start_ipfs] : "
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '
ls -alh /usr/local/bin/container_init_run
ls -alh /usr/local/bin/start_ipfs
cat /usr/local/bin/start_ipfs
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '
echo ''
echo ''
echo 'Start command is :'
echo ''
echo "[/usr/local/bin/start_ipfs $@]"
echo ''
echo '# --- # --- # --- # --- # --- # --- # --- # --- # '


/usr/local/bin/start_ipfs $@



exit 0
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### REFERENCE CONFIG FROM 'ipfs config show'
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ipfs1         |  Checking IPFS config [ipfs config show]
# ipfs1         |
# ipfs1         | {
# ipfs1         |   "API": {
# ipfs1         |     "HTTPHeaders": {
# ipfs1         |       "Access-Control-Allow-Methods": [
# ipfs1         |         "GET",
# ipfs1         |         "PATCH",
# ipfs1         |         "DELETE",
# ipfs1         |         "PUT",
# ipfs1         |         "POST"
# ipfs1         |       ],
# ipfs1         |       "Access-Control-Allow-Origin": [
# ipfs1         |         "http://onedev.pokus.io:5001",
# ipfs1         |         "http://localhost:3000",
# ipfs1         |         "http://127.0.0.1:5001",
# ipfs1         |         "https://webui.ipfs.io"
# ipfs1         |       ]
# ipfs1         |     }
# ipfs1         |   },
# ipfs1         |   "Addresses": {
# ipfs1         |     "API": "/ip4/0.0.0.0/tcp/5001",
# ipfs1         |     "Announce": [],
# ipfs1         |     "AppendAnnounce": [],
# ipfs1         |     "Gateway": "/ip4/0.0.0.0/tcp/8080",
# ipfs1         |     "NoAnnounce": [],
# ipfs1         |     "Swarm": [
# ipfs1         |       "/ip4/0.0.0.0/tcp/4001",
# ipfs1         |       "/ip6/::/tcp/4001",
# ipfs1         |       "/ip4/0.0.0.0/udp/4001/quic",
# ipfs1         |       "/ip4/0.0.0.0/udp/4001/quic-v1",
# ipfs1         |       "/ip4/0.0.0.0/udp/4001/quic-v1/webtransport",
# ipfs1         |       "/ip6/::/udp/4001/quic",
# ipfs1         |       "/ip6/::/udp/4001/quic-v1",
# ipfs1         |       "/ip6/::/udp/4001/quic-v1/webtransport"
# ipfs1         |     ]
# ipfs1         |   },
# ipfs1         |   "AutoNAT": {},
# ipfs1         |   "Bootstrap": [
# ipfs1         |     "/dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa",
# ipfs1         |     "/dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb",
# ipfs1         |     "/dnsaddr/bootstrap.libp2p.io/p2p/QmcZf59bWwK5XFi76CZX8cbJ4BhTzzA3gU1ZjYZcYW3dwt",
# ipfs1         |     "/ip4/104.131.131.82/tcp/4001/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
# ipfs1         |     "/ip4/104.131.131.82/udp/4001/quic/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
# ipfs1         |     "/dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN"
# ipfs1         |   ],
# ipfs1         |   "DNS": {
# ipfs1         |     "Resolvers": {}
# ipfs1         |   },
# ipfs1         |   "Datastore": {
# ipfs1         |     "BloomFilterSize": 0,
# ipfs1         |     "GCPeriod": "1h",
# ipfs1         |     "HashOnRead": false,
# ipfs1         |     "Spec": {
# ipfs1         |       "mounts": [
# ipfs1         |         {
# ipfs1         |           "child": {
# ipfs1         |             "path": "blocks",
# ipfs1         |             "shardFunc": "/repo/flatfs/shard/v1/next-to-last/2",
# ipfs1         |             "sync": true,
# ipfs1         |             "type": "flatfs"
# ipfs1         |           },
# ipfs1         |           "mountpoint": "/blocks",
# ipfs1         |           "prefix": "flatfs.datastore",
# ipfs1         |           "type": "measure"
# ipfs1         |         },
# ipfs1         |         {
# ipfs1         |           "child": {
# ipfs1         |             "compression": "none",
# ipfs1         |             "path": "datastore",
# ipfs1         |             "type": "levelds"
# ipfs1         |           },
# ipfs1         |           "mountpoint": "/",
# ipfs1         |           "prefix": "leveldb.datastore",
# ipfs1         |           "type": "measure"
# ipfs1         |         }
# ipfs1         |       ],
# ipfs1         |       "type": "mount"
# ipfs1         |     },
# ipfs1         |     "StorageGCWatermark": 90,
# ipfs1         |     "StorageMax": "10GB"
# ipfs1         |   },
# ipfs1         |   "Discovery": {
# ipfs1         |     "MDNS": {
# ipfs1         |       "Enabled": true
# ipfs1         |     }
# ipfs1         |   },
# ipfs1         |   "Experimental": {
# ipfs1         |     "FilestoreEnabled": false,
# ipfs1         |     "GraphsyncEnabled": false,
# ipfs1         |     "Libp2pStreamMounting": false,
# ipfs1         |     "OptimisticProvide": false,
# ipfs1         |     "OptimisticProvideJobsPoolSize": 0,
# ipfs1         |     "P2pHttpProxy": false,
# ipfs1         |     "StrategicProviding": false,
# ipfs1         |     "UrlstoreEnabled": false
# ipfs1         |   },
# ipfs1         |   "Gateway": {
# ipfs1         |     "APICommands": [],
# ipfs1         |     "DeserializedResponses": null,
# ipfs1         |     "HTTPHeaders": {},
# ipfs1         |     "NoDNSLink": false,
# ipfs1         |     "NoFetch": false,
# ipfs1         |     "PathPrefixes": [],
# ipfs1         |     "PublicGateways": null,
# ipfs1         |     "RootRedirect": ""
# ipfs1         |   },
# ipfs1         |   "Identity": {
# ipfs1         |     "PeerID": "12D3KooWH5NYcHT478pca9eAejGh5jDGvTRszNZSBJH1TFFcnHs1"
# ipfs1         |   },
# ipfs1         |   "Internal": {},
# ipfs1         |   "Ipns": {
# ipfs1         |     "RecordLifetime": "",
# ipfs1         |     "RepublishPeriod": "",
# ipfs1         |     "ResolveCacheSize": 128
# ipfs1         |   },
# ipfs1         |   "Migration": {
# ipfs1         |     "DownloadSources": [],
# ipfs1         |     "Keep": ""
# ipfs1         |   },
# ipfs1         |   "Mounts": {
# ipfs1         |     "FuseAllowOther": false,
# ipfs1         |     "IPFS": "/ipfs",
# ipfs1         |     "IPNS": "/ipns"
# ipfs1         |   },
# ipfs1         |   "Peering": {
# ipfs1         |     "Peers": null
# ipfs1         |   },
# ipfs1         |   "Pinning": {
# ipfs1         |     "RemoteServices": {}
# ipfs1         |   },
# ipfs1         |   "Plugins": {
# ipfs1         |     "Plugins": null
# ipfs1         |   },
# ipfs1         |   "Provider": {
# ipfs1         |     "Strategy": ""
# ipfs1         |   },
# ipfs1         |   "Pubsub": {
# ipfs1         |     "DisableSigning": false,
# ipfs1         |     "Router": ""
# ipfs1         |   },
# ipfs1         |   "Reprovider": {},
# ipfs1         |   "Routing": {
# ipfs1         |     "AcceleratedDHTClient": false,
# ipfs1         |     "Methods": null,
# ipfs1         |     "Routers": null
# ipfs1         |   },
# ipfs1         |   "Swarm": {
# ipfs1         |     "AddrFilters": null,
# ipfs1         |     "ConnMgr": {},
# ipfs1         |     "DisableBandwidthMetrics": false,
# ipfs1         |     "DisableNatPortMap": false,
# ipfs1         |     "RelayClient": {},
# ipfs1         |     "RelayService": {},
# ipfs1         |     "ResourceMgr": {},
# ipfs1         |     "Transports": {
# ipfs1         |       "Multiplexers": {},
# ipfs1         |       "Network": {},
# ipfs1         |       "Security": {}
# ipfs1         |     }
# ipfs1         |   }
# ipfs1         | }
