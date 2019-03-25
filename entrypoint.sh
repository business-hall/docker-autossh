#!/bin/bash
keyFile=${SSH_PRIV_KEY_FILE}
#extVol=`pwd`/extvol
if test ! -e ${keyFile}; then
  echo "Could not find SSH key for public host ${keyFile}, quitting !"
  exit 1
fi
chmod 0400 ${keyFile}
mapping=
hosts=
pub2PrivFile=${PUB_TO_PRIV_FILE}
if test -e ${pub2PrivFile}; then
  for line in `cat ${pub2PrivFile}`; do
    firstChar=$(echo $line | cut -c1)
    if test "${firstChar}" = "#"; then
      continue
    fi
    mapping="${mapping} -R ${line}"
    host=`echo $line | cut -f2 -d':'`
    if [[ ${hosts} != *"${host}"* ]]; then
      dig $host
      hosts="${host} ${hosts}"
    fi
  done
fi
priv2PubFile=${PRIV_TO_PUB_FILE}
if test -e ${priv2PubFile}; then
  for line in `cat ${priv2PubFile}`; do
    firstChar=$(echo $line | cut -c1)
    if test "${firstChar}" = "#"; then
      continue
    fi
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