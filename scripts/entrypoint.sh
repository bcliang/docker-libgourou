#!/bin/bash -e

ACSM_FILE=$1
ACSM_PATH=/home/libgourou/files/$ACSM_FILE

# OUTPUT_FILE=name=$(basename "$ACSM_PATH" .acsm) 
acsmdownloader --version
echo ""[util] acsmdownloader -f "$ACSM_PATH"""
OUTPUT_FILE=$(acsmdownloader -f "$ACSM_PATH" | egrep "epub|pdf" | cut -d " " -f 2)
echo "      > $OUTPUT_FILE"
mv $OUTPUT_FILE "output.drm"
adept_remove -f "output.drm" -o "${ACSM_PATH%.*}.${OUTPUT_FILE##*.}"

exec "$@"