# FROM python:3.10-slim-bullseye
FROM ubuntu:jammy

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ="America\Los_Angeles" \
  apt-get install -y \
  build-essential \
  bash \
  git \
  wget \
  libzip-dev \
  libssl-dev \
  libcurl4-gnutls-dev \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# RUN apt-get install -y valgrind

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

RUN apt-get remove -y git build-essential \
  && apt-get clean


COPY scripts /home/libgourou

WORKDIR /home/libgourou

ENTRYPOINT ["/bin/bash", "/home/libgourou/entrypoint.sh"]
