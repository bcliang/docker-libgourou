# FROM python:3.10-slim-bullseye
FROM ubuntu:jammy

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ="America\Los_Angeles" \
  apt-get install -y \
  build-essential \
  bash \
  git \
  wget \
  curl \
  tzdata \
  libzip-dev \
  libssl-dev \
  libcrypto++-dev \
  libcurl4-gnutls-dev \
  # libqt5core5a \
  # libqt5network5 \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# RUN apt-get install -y valgrind

# RUN cp -r usr/include/x86_64-linux-gnu/curl usr/include/curl \
RUN cd /usr/src \
  && git clone git://soutade.fr/libgourou.git \
  && cd libgourou \
  && make \
  && cp /usr/src/libgourou/libgourou.so         /usr/local/lib \
  && cp /usr/src/libgourou/utils/acsmdownloader /usr/local/bin \
  && cp /usr/src/libgourou/utils/adept_activate /usr/local/bin \
  && cp /usr/src/libgourou/utils/adept_remove   /usr/local/bin \
  && cd ~ \
  && rm -r /usr/src/libgourou \
  && ldconfig

# RUN apt-get remove -y git build-essential 
COPY scripts /home/libgourou

WORKDIR /home/libgourou

#CMD for file in *.acsm; do knock "$(pwd)"/$file; done

ENTRYPOINT ["/bin/bash", "/home/libgourou/entrypoint.sh"]
