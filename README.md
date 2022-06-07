# docker-libgourou

Dockerized version of libgourou. libgourou is a free implementation of Adobe's ADEPT protocol used to add DRM on ePub/PDF files. It overcome the lacks of Adobe support for Linux platforms.

## libgourou

https://indefero.soutade.fr/p/libgourou/

### utils

This container compiles the reference implementation utilities for libgourou (master branch) and places them in `/usr/local/bin` for easy access. 

- `acsmdownloader` for downloading ePub/PDF files from Adobe's CDN
- `adept_remove` for removing ADEPT DRM from a ADEPT-protected ePub/PDF
- `adept_loan_mgt` for managing ADEPT loan library

## Installation

```bash
> docker build . -t bcliang/docker-libgourou
```

## Usage

### Automated download and de-drm

By default, the container will process an inputted *.acsm file ($1) through both `acsmdownloader` (to retreive the PDF/ePub file) and `adept_remove` (to remove ADEPT DRM from the downloaded book). 

```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd):/home/libgourou/files \
    -it \
    --rm bcliang/docker-libgourou \
    [name_of_adept_metafile.acsm]
```

### Interactive Shell

To manually run libgourou utils, change the docker entrypoint
```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd):/home/libgourou/files \
    -it --entrypoint /bin/bash \
    --rm bcliang/docker-libgourou
```


