FROM debian:stretch-slim

ENV \
    TERM=xterm \
    AUTOSSH_LOGFILE=/dev/stdout \
    AUTOSSH_GATETIME=30         \
    AUTOSSH_POLL=10             \
    AUTOSSH_FIRST_POLL=30       \
    AUTOSSH_LOGLEVEL=1

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install openssh-client build-essential wget dnsutils

RUN mkdir -p /app/src && \
    wget -O /app/tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 && \
    wget -O /app/src/autossh-1.4g.tgz https://www.harding.motd.ca/autossh/autossh-1.4g.tgz && \
    tar -xvf /app/src/autossh-1.4g.tgz -C /app/src && \
    cd /app/src/autossh-1.4g && \
    ./configure && \
    make install && \
    rm -rf /app/src/ && \
    apt-get -y remove build-essential && \
    apt-get -y autoremove 

VOLUME /app/extvol
ADD entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/tini && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/tini", "-s", "--"]
CMD ["/bin/bash", "-c", "/app/entrypoint.sh"]
