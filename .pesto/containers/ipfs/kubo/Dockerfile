# ARG KUBO_VERSION=latest
ARG KUBO_VERSION
# It's a FROM busybox:stable-glibc
FROM ipfs/kubo:$KUBO_VERSION
ARG KUBO_VERSION=$KUBO_VERSION

# Fix permissions on start_ipfs (ignore the build machine's permissions)
# RUN chmod 0755 /usr/local/bin/start_ipfs

# ---
# # Create the fs-repo directory and switch to a non-privileged user.
# ENV IPFS_PATH /data/ipfs
# RUN mkdir -p $IPFS_PATH \
#   && adduser -D -h $IPFS_PATH -u 1000 -G users ipfs \
#   && chown ipfs:users $IPFS_PATH
# ---
# below, custom entrypoint to pre-configure the cors at startup
RUN mkdir -p /usr/local/bin/pesto && chown ipfs:users /usr/local/bin/pesto
COPY entrypoint.sh /usr/local/bin/pesto
RUN chmod 0755 /usr/local/bin/pesto/entrypoint.sh
RUN chmod a+x /usr/local/bin/pesto/*.sh

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
ENTRYPOINT ["/usr/local/bin/pesto/entrypoint.sh", "--"]

# # Healthcheck for the container
# # QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn is the CID of empty folder
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#   CMD ipfs --api=/ip4/127.0.0.1/tcp/5001 dag stat /ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn || exit 1

# Execute the daemon subcommand by default
CMD ["daemon", "--migrate=true", "--agent-version-suffix=docker"]