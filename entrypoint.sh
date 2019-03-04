#!/bin/bash
keyFile=/app/extvol/public-host.priv
if test ! -e ${keyFile}; then
  echo "Could not find SSH key for public host ${keyFile}, quitting !"
  exit 1
fi
chmod 0400 ${keyFile}
mapping=
hosts=
pub2PrivFile=/app/extvol/pub2priv.txt
if test -e ${pub2PrivFile}; then
  for line in `cat ${pub2PrivFile}`; do
    mapping="${mapping} -R ${line}"
    host=`echo $line | cut -f2 -d':'`
    if [[ ${hosts} != *"${host}"* ]]; then
      nslookup $host
      hosts="${host} ${hosts}"
    fi
  done
fi
priv2PubFile=/app/extvol/priv2pub.txt
if test -e ${priv2PubFile}; then
  for line in `cat ${priv2PubFile}`; do
    mapping=$mapping -L $line
  done
fi
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
 ${mapping}
 ${SSH_PUBLIC_HOSTUSER}@${SSH_PUBLIC_HOSTNAME}
EOF
)
echo Running ${cmd}
AUTOSSH_POLL=10 \
AUTOSSH_LOGLEVEL=0 \
AUTOSSH_LOGFILE=/dev/stdout \
${cmd}
