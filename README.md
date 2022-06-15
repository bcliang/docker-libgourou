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
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -u $(id -u ${USER}):$(id -g ${USER})
    -it --entrypoint /bin/bash \
    bcliang/docker-libgourou
```

#### Commands

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

#### bash script

A "de-DRM" bash script is provided (`./scripts/dedrm.sh`) to simplify running and using the docker-libgourou image.

```bash
> chmod +x scripts/dedrm.sh
> cp scripts/dedrm.sh ~/.local/bin/dedrm
```

To launch an interactive terminal with access to the libgourou utils:
```bash
> dedrm
!!!
!!!    WARNING: no ADEPT keys detected (argument $2, or "$(pwd)/.adept").
!!!    Launching interactive terminal for credentials creation (device activation). Run this:
!!!
!!!    adept_activate -r --username {USERNAME} --password {PASSWORD} --output-dir files/.adept
!!!
!!!     (*) use --anonymous in place of --username, --password if you do not have an ADE account.
!!!     (*) credentials will be saved in your current path in the folder "$(pwd)/.adept"
!!!
!!!
!!!    WARNING: no ACSM file detected (argument $1).
!!!    Launching interactive terminal for manual loan management. Example commands below:
!!!
!!!    acsmdownloader -f "./files/{ACSM_FILE}" -o output.drm
!!!    adept_remove -v -f output.drm -o "/home/libgourou/files/{OUTPUT_FILE}"
!!!
root@..:/home/libgourou# 
```

To generate a DRM-removed PDF/ePub file (this simply replicates the command at the top of this section):
```bash
> dedrm {ACSM_FILE}
```

To generate a DRM-free PDF/ePub file using credentials in a specific directory:
```bash
> dedrm {ACSM_FILE} {CREDENTIALS_PATH}
```