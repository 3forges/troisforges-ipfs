#!/bin/sh

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start_ipfs"]

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
echo 'Start command is :'
echo ''
echo "[npm start $@]"
echo ''

/sbin/tini $@