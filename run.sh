sudo docker stop autossh-capture-tunnel && \
  sudo docker rm autossh-capture-tunnel; \
  sudo docker run -d --restart unless-stopped --name autossh-capture-tunnel \
    -e SSH_PUBLIC_HOSTUSER=ubuntu \
    -e SSH_PUBLIC_HOSTNAME=<public host> \
    -e SSH_PRIV_KEY_FILE=/app/extvol/ssh-priv.key \
    -e PUB_TO_PRIV_FILE=/app/extvol/pub2priv.txt \
    -e PRIV_TO_PUB_FILE=/app/extvol/priv2pub.txt \
    -v `pwd`/extvol:/app/extvol autossh-capture-tunnel
