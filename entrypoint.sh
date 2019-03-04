#!/bin/bash
keyFile=/app/extvol/public-host.priv
if test ! -e ${keyFile}; then
  echo "Could not find SSH key for public host ${keyFile}, quitting !"
  exit 1
fi
chmod 0400 ${keyFile}
cmd=$(cat <<EOF
autossh
 -M 0
 -i ${keyFile}
 -N
 -o StrictHostKeyChecking=no 
 -o ServerAliveInterval=5
 -o ServerAliveCountMax=1
 -o ExitOnForwardFailure=yes
 -t
 -R 20022:${SSH_PRIVATE_HOSTNAME}:22
 -R 20443:${SSH_PRIVATE_HOSTNAME}:443
 ${SSH_PUBLIC_HOSTUSER}@${SSH_PUBLIC_HOSTNAME}
EOF
)

nslookup ${SSH_PRIVATE_HOSTNAME}
echo Running ${cmd}
AUTOSSH_POLL=10 \
AUTOSSH_LOGLEVEL=0 \
AUTOSSH_LOGFILE=/dev/stdout \
${cmd}
