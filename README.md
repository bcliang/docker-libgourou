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
> docker build . -f Dockerfile-ubuntu -t bcliang/docker-libgourou
```

or on alpine:
```bash
> docker build . -f Dockerfile-alpine -t bcliang/docker-libgourou
```

### DockerHub

```bash
> docker pull bcliang/docker-libgourou:latest
```

The `:latest` tag will pull the `:ubuntu` image. Use `:ubuntu` or `:alpine` to specify the desired base image (warning: segmentation faults when running the alpine build in `0.8.4`).

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

Notes: 
1. The shell script assumes that activated device configuration files (via Adobe ID credentials) have been mounted into `/home/libgourou` (alternates: `/home/libgourou/.adept/`, `/home/libgourou/adobe-digital-editions/`, etc.). 
2. To generate ADEPT configuration files (`activation.xml`, `devicesalt`, `device.xml`), use the interactive terminal and run the `adept_activate` utility.

### Interactive Terminal

To manually run libgourou utils, run the container interactively and overide the docker entrypoint:
```bash
> docker run \
    -v {$PATH_TO_ADOBE_CREDS}:/home/libgourou/.adept \
    -v $(pwd):/home/libgourou/files \
    -it --entrypoint /bin/bash \
    bcliang/docker-libgourou
```

#### Commands

Use the bash shell to run the libgourou utility scripts. See the `libgourou` [README](https://indefero.soutade.fr/p/libgourou/source/tree/master/README.md) and/or the included manpages for additional usage.

To activate a new device with a AdobeID :
```
adept_activate -u <AdobeID USERNAME> [--output-dir output_directory]
```
By default, configuration files will be saved in `/home/libgourou/.adept`. Users should save contents to a mounted volume for reuse at a later date.

To download an ePub/PDF :
```
acsmdownloader <ACSM_FILE>
```
To export your private key (for use with Calibre, for example) :
```
acsmdownloader --export-private-key [-o adobekey_1.der]
```
To remove ADEPT DRM :
```
adept_remove <encrypted_file>
```
To list loaned books :
```
adept_loan_mgt [-l]
```
To return a loaned book :
```
adept_loan_mgt -r <id>
```

### Bash Script

A "de-DRM" bash script is provided (`./scripts/dedrm.sh`) to simplify running and using the docker-libgourou image.

```bash
> chmod +x scripts/dedrm.sh
> cp scripts/dedrm.sh ~/.local/bin/dedrm
```

To launch an interactive terminal with access to the libgourou utils:
```bash
> dedrm
!!!    WARNING: no ADEPT keys detected (argument $2, or "$HOME_DIR/.config/adept").
!!!    Launching interactive terminal for credentials creation (device activation). Run this:

 > adept_activate --random-serial \
       --username {USERNAME} \
       --password {PASSWORD} \
       --output-dir files/adept

!!!     (*) use --anonymous in place of --username, --password if you do not have an ADE account.
!!!     (*) credentials will be saved in the following path: "$(pwd)/adept"

!!!    WARNING: no ACSM file detected (argument $1).
!!!    Launching interactive terminal for manual loan management. Example commands below:

 > acsmdownloader \
       --adept-directory .adept \
       --output-file encrypted_file.drm \
       "files/{ACSM_FILE}"
 > adept_remove \
       --adept-directory .adept \
       --output-dir files \
       --output-file "{OUTPUT_FILE}" \
       encrypted_file.drm

Mounted Volumes
   (current path e.g. $pwd) --> /home/libgourou/files/

root@..:/home/libgourou# 
```

If you already have ADEPT keys saved (i.e. in `.adept` or `~/.config/adept`), append the encrypted ACSM file path in order to automatically generate a DRM-removed PDF/ePub file (this simply replicates the command at the top of this section):
```bash
> dedrm {ACSM_FILE}
```

To generate a DRM-free PDF/ePub file using credentials in a specific path:
```bash
> dedrm {ACSM_FILE} {CREDENTIALS_PATH}
```