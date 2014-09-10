FROM ubuntu:14.04
MAINTAINER Nathan W. <nathan@frcv.net>

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      debhelper \
      e2fslibs-dev \
      libacl1-dev \
      libattr1-dev \
      libbz2-dev \
      libssl-dev \
      wget \
      zlib1g-dev

ADD https://www.tarsnap.com/tarsnap-signing-key.asc /tmp/

ENV ver 1.0.35
ADD https://www.tarsnap.com/download/tarsnap-autoconf-$ver.tgz /tmp/
ADD https://www.tarsnap.com/download/tarsnap-sigs-$ver.asc /tmp/

RUN gpg --import /tmp/tarsnap-signing-key.asc && \
    asc=$(gpg --decrypt /tmp/tarsnap-sigs-$ver.asc | awk '/SHA256/ { print $4 }') && \
    tgz=$(openssl dgst -sha256 /tmp/tarsnap-autoconf-$ver.tgz | awk '{ print $2 }') && \
    if [ "$asc" != "$tgz" ]; then exit 1; fi


RUN tar -zxvf /tmp/tarsnap-autoconf-$ver.tgz -C /tmp/ && \
    cd /tmp/tarsnap* && \
    ln -s pkg/debian . && \
    dpkg-buildpackage

ADD installer /installer
CMD /installer

    
