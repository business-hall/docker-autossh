FROM alpine:latest

ENV \
    TERM=xterm \
    AUTOSSH_LOGFILE=/dev/stdout \
    AUTOSSH_GATETIME=30         \
    AUTOSSH_POLL=10             \
    AUTOSSH_FIRST_POLL=30       \
    AUTOSSH_LOGLEVEL=1

RUN apk update && \
    apk add openssh-client bind-tools build-base bash

COPY ./zips /app/zips
COPY ./pre-baked /app/pre-baked
RUN mkdir -p /app/build && \
    if test ! -f /app/zips/autossh-1.4g.tgz; then \
      wget -O /app/zips/autossh-1.4g.tgz https://www.harding.motd.ca/autossh/autossh-1.4g.tgz; \
    fi  && \
    tar -xvf /app/zips/autossh-1.4g.tgz -C /app/build && \
    cd /app/build/autossh-1.4g && \
    ./configure && \
    make install && \
    rm -r /app/build/autossh-1.4g && \
    apk del build-base && \
    if test ! -f /app/pre-baked/tini-static-amd64; then \
      wget -O /app/pre-baked/tini-static-amd64 https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 && \
    fi 

VOLUME /app/extvol
ADD entrypoint.sh /app/scripts/entrypoint.sh
RUN chmod +x /app/scripts/entrypoint.sh

ENTRYPOINT ["/app/pre-baked/tini-static-amd64", "-s", "--"]
CMD ["/bin/bash", "-c", "/app/scripts/entrypoint.sh"]
