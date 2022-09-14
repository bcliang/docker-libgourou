#!/bin/bash -e

ACSM_FILE=$1
KEY_PATH=$2

# Docker container needs a well-defined path for mounting volumes (paths should start with /* or ./*). 
# Check $KEY_PATH and attempt to convert relative paths when necessary
if [[ ! -z "$KEY_PATH" ]] && [[ -d "$KEY_PATH" ]]
then
    # user specified a path AND bash found the directory
    case $KEY_PATH in
        /*)
            # absolute path, do nothing
            ;;
        ~*)
            # home directory, convert to absolute path
            HOME_DIR="$(getent passwd $USER | awk -F ':' '{print $6}')"
            KEY_PATH="$HOME_DIR/${KEY_PATH:1}"
            ;;
        *)
            # relative path, convert
            KEY_PATH="$(pwd)/$KEY_PATH"
            ;;
    esac
else
    # user didn't specify a path
    if [[ -z "$KEY_PATH" ]]
    then
        if [[ -d "$(pwd)/.adept" ]]
        then
            # check the script's "default" path
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
fi

# *.acsm file not specified, or specified file doesn't exist
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

if [[ -z "$KEY_PATH" ]]
then
    # ADEPT keys missing; can't run libgourou utils
    echo -e "\nMounted Volumes"
    echo -e "   $(pwd) --> /home/libgourou/files/\n"
    docker run \
        -v "$(pwd)":/home/libgourou/files \
        -it --entrypoint /bin/bash \
        --rm bcliang/docker-libgourou
else
    if [[ -z "$ACSM_FILE" ]] || [[ ! -f "$ACSM_FILE" ]]
    then
        # ADEPT keys were found but no *.acsm file
        echo -e "\nMounted Volumes"
        echo -e "   $(pwd) --> /home/libgourou/files/"
        echo -e "   $KEY_PATH --> mounted at /home/libgourou/.adept/\n"
        docker run \
            -v "$(pwd)":/home/libgourou/files \
            -v "$KEY_PATH":/home/libgourou/.adept \
            -it --entrypoint /bin/bash \
            --rm bcliang/docker-libgourou
    else
        # both ADEPT keys and *.acsm file were found
        echo "> acsmdownloader -f \"/home/libgourou/files/$ACSM_FILE\" -o \"output.drm\""
        echo "> adept_remove -v -f \"output.drm\" -o \"/home/libgourou/files/{OUTPUT_FILE}\""
        docker run \
            -v "$(pwd)":/home/libgourou/files \
            -v "$KEY_PATH":/home/libgourou/.adept \
            --rm bcliang/docker-libgourou \
            $ACSM_FILE
    fi
fi

