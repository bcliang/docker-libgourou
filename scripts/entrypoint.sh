#!/bin/bash -e

ACSM_FILE=$1
ACSM_PATH=/home/libgourou/files/$ACSM_FILE

acsmdownloader --version
echo ""[util] acsmdownloader "$ACSM_PATH"""

OUTPUT_FILE=$(acsmdownloader --adept-directory .adept "$ACSM_PATH" | egrep "epub|pdf" | cut -d " " -f 2-)
echo "      > $OUTPUT_FILE"

mv "$OUTPUT_FILE" "encrypted_file.drm"

adept_remove \
  --adept-directory .adept \
  --output-dir files \
  --output-file "$OUTPUT_FILE" \
  "encrypted_file.drm"
