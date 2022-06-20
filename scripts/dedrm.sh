#!/bin/bash -e

ACSM_FILE=$1
KEY_PATH=$2

if [[ -z "$KEY_PATH" ]] || [[ ! -d "$KEY_PATH" ]]
then
    if [[ -d "$(pwd)/.adept" ]]
    then
        KEY_PATH="$(pwd)/.adept"
    else
        echo "!!!"
        echo "!!!    WARNING: no ADEPT keys detected (argument \$2, or \"$(pwd)/.adept\")."
        echo "!!!    Launching interactive terminal for credentials creation (device activation). Run this:"
        echo "!!!"
        echo "!!!    adept_activate -r --username {USERNAME} --password {PASSWORD} --output-dir files/.adept"
        echo "!!!"
        echo "!!!     (*) use --anonymous in place of --username, --password if you do not have an ADE account."
        echo "!!!     (*) credentials will be saved in your current path in the folder \"$(pwd)/.adept\""
        echo "!!!"
    fi
fi

if [[ -z "$ACSM_FILE" ]] || [[ ! -f "$ACSM_FILE" ]]
then
    echo "!!!"
    echo "!!!    WARNING: no ACSM file detected (argument \$1)."
    echo "!!!    Launching interactive terminal for manual loan management. Example commands below:"
    echo "!!!"
    echo "!!!    acsmdownloader -f \"./files/{ACSM_FILE}\" -o output.drm"
    echo "!!!    adept_remove -v -f output.drm -o \"/home/libgourou/files/{OUTPUT_FILE}\""
    echo "!!!"
fi

if [[ -z "$KEY_PATH" ]] || [[ -z "$ACSM_FILE" ]] || [[ ! -f "$ACSM_FILE" ]]
then
    echo "Note: the current path ($(pwd)) will be mounted at /home/libgourou/files"
    docker run \
        -v "$(pwd)":/home/libgourou/files \
        -v "$(pwd)/$KEY_PATH":/home/libgourou/.adept \
        -it --entrypoint /bin/bash \
        --rm bcliang/docker-libgourou 
else
    echo "> acsmdownloader -f \"/home/libgourou/files/$ACSM_FILE\" -o \"output.drm\""
    echo "> adept_remove -v -f \"output.drm\" -o \"/home/libgourou/files/{OUTPUT_FILE}\""
    docker run \
        -v "$(pwd)":/home/libgourou/files \ 
        -v "$(pwd)/$KEY_PATH":/home/libgourou/.adept \
        --rm bcliang/docker-libgourou \
        $ACSM_FILE
fi

