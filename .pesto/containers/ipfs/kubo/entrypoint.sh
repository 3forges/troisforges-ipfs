#!/bin/sh

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start_ipfs"]
echo ''
echo ''
echo "Configuring CORS of IPFS/KUBO server"
echo ''
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://onedev.pokus.io:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["GET", "PATCH", "DELETE", "PUT", "POST"]'
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
chmod a+rw /data/ipfs/config
chmod a+rw -R /data/ipfs/

/usr/local/bin/start_ipfs $@