FROM arm32v7/debian:buster

LABEL maintainer="chad.hutchins@yahoo.com"

ENV BIND_USER=bind \
    BIND_VERSION=9.17.5 \
    WEBMIN_VERSION=1.955 \
    DATA_DIR=/data

ENV DEBIAN_FRONTEND noninteractive    # export DEBIAN_FRONTEND="noninteractive"

RUN ln -sf /bin/bash /bin/sh

###
### Install
###
RUN apt-get update \
    && apt-get install -y gnupg \
    && apt-key adv --fetch-keys https://download.webmin.com/jcameron-key.asc \
    && echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list 

RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes \
    && apt-get purge apt-show-versions \ 
    && rm /var/lib/apt/lists/*lz4 \
    && apt-get -o Acquire::GzipIndexes=false update \ 
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    bind9 \
    bind9-host \
    dnsutils \
    webmin=${WEBMIN_VERSION}* \
    iputils-ping \
    && rm -r /var/lib/apt/lists/* \
    && mkdir /var/log/named \
    && chown bind:bind /var/log/named \
    && chmod 0755 /var/log/named

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
