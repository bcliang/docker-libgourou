# build apps
FROM ubuntu:jammy AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ="America\Los_Angeles" \
    apt-get install -y \
    g++ \
    libpugixml-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libzip-dev \
    make \
    bash \
    git

WORKDIR /usr/src

RUN git clone git://soutade.fr/libgourou.git \
  && cd libgourou \
  && make BUILD_STATIC=1


# copy from builder to runtime image
FROM ubuntu:jammy

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ="America\Los_Angeles" \ 
    apt-get install -y \
    libcurl4 \
    libzip4 \
    libpugixml1v5 \
    bash

COPY --from=builder /usr/src/libgourou/utils/acsmdownloader \
                    /usr/src/libgourou/utils/adept_activate \
                    /usr/src/libgourou/utils/adept_remove \
                    /usr/local/bin/

WORKDIR /home/libgourou
COPY scripts .

ENTRYPOINT ["/bin/bash", "/home/libgourou/entrypoint.sh"]
