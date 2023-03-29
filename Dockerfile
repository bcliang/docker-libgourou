# build apps
FROM alpine:latest AS builder

RUN apk add g++ \
    pugixml-dev \
    openssl-dev \
    curl-dev \
    libzip-dev \
    make \
    bash \
    git

WORKDIR /usr/src

RUN git clone git://soutade.fr/libgourou.git \
  && cd libgourou \
  && make BUILD_STATIC=1


# copy from builder to runtime image
FROM alpine:latest

RUN apk add --no-cache \
  libcurl \
  libzip \
  pugixml \
  bash

COPY --from=builder /usr/src/libgourou/utils/acsmdownloader \
                    /usr/src/libgourou/utils/adept_activate \
                    /usr/src/libgourou/utils/adept_remove \
                    /usr/local/bin/

WORKDIR /home/libgourou
COPY scripts .

ENTRYPOINT ["/bin/bash", "/home/libgourou/entrypoint.sh"]
