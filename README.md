# docker-libgourou

Dockerized version of libgourou. libgourou is a free implementation of Adobe's ADEPT protocol. ADEPT is used to manage loaned ePub/PDF titles (checkout/return). It is also used to manage DRM in loaned ePub/PDF files. 

## libgourou

libgourou requires an Adobe ID but runs on Linux platforms (no WINE-based workaround required).

https://indefero.soutade.fr/p/libgourou/

### utils

This container compiles the reference implementation utilities for libgourou (master branch) and places them in `/usr/local/bin` for easy access. 

- `acsmdownloader` for downloading ePub/PDF files from Adobe's CDN
- `adept_activate` for activating user device via Adobe ID
- `adept_loan_mgt` for managing ADEPT loan library
- `adept_remove` for removing ADEPT DRM from an ADEPT-protected ePub/PDF

## Installation

### Local Build

```bash
> docker build . -t bcliang/docker-libgourou
```

## Usage

### Automated download and de-drm

By default, the container will process an inputted *.acsm file ($1) through both `acsmdownloader` (to retreive the PDF/ePub file) and `adept_remove` (to remove ADEPT DRM from the downloaded file). 

```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd):/home/libgourou/files \
    --rm bcliang/docker-libgourou \
    [name_of_adept_metafile.acsm]
```

Notes: The shell script assumes that activated device configuration files (via Adobe ID credentials) have been mounted in the home directory (e.g. in `/home/libgourou`, `/home/libgourou/.adept/`, or `/home/libgourou/adobe-digital-editions/`). 

To generate ADEPT configuration files (`activation.xml`, `devicesalt`, `device.xml`), use the interactive terminal and run `adept_activate`

### Interactive Terminal

To manually run libgourou utils, run the container interactively and overide the docker entrypoint :
```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd):/home/libgourou/files \
    -it --entrypoint /bin/bash \
    bcliang/docker-libgourou
```

Use the bash shell to run the libgourou utility scripts. See the `libgourou` [README](https://indefero.soutade.fr/p/libgourou/source/tree/master/README.md) for additional notes.

To activate a new device with a AdobeID :
```
adept_activate -u <AdobeID USERNAME> [--output-dir output_directory]
```
By default, configuration files will be saved in `/home/libgourou/.adept`. Save contents to a mounted volume for reuse at a later date.

To download an ePub/PDF :
```
acsmdownloader -f <ACSM_FILE>
```
To export your private key (for use with Calibre, for example) :
```
acsmdownloader --export-private-key [-o adobekey_1.der]
```
To remove ADEPT DRM :
```
adept_remove -f <encryptedFile>
```
To list loaned books :
```
adept_loan_mgt [-l]
```
To return a loaned book :
```
adept_loan_mgt -r <id>
```
