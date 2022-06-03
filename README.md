# docker-libgourou

Dockerized version of libgourou. libgourou is a free implementation of Adobe's ADEPT protocol used to add DRM on ePub/PDF files. It overcome the lacks of Adobe support for Linux platforms.

## libgourou

https://indefero.soutade.fr/p/libgourou/

### utils

This container compiles the reference implementation utilities for libgourou and places them in `/usr/local/bin` for easy access.

- `acsmdownloader` for downloading ePub/PDF files from Adobe's CDN
- `adept_remove` for removing ADEPT DRM from a ADEPT-protected ePub/PDF
- `adept_loan_mgt` for managing ADEPT loan library

## Installation

```bash
> docker build -f Dockerfile -t bcliang/docker-libgourou
```

## Usage

### Automated download and de-drm

The container will default to sequentially running first the `acsmdownloader` followed by the `adept_remove` utility application to process the *.acsm file referenced in $1

```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd)/bin:/home/libgourou/files \
    -it \
    --rm docker-libgourou \
    [name_of_adept_metafile.acsm]
```

### Interactive Shell

To manually run libgourou utils, change the docker entrypoint
```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd)/bin:/home/libgourou/files \
    -it --entrypoint /bin/bash \
    --rm docker-libgourou
```


