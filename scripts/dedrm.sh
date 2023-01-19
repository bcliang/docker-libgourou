#!/bin/bash -e

ACSM_FILE=$1
KEY_PATH=$2
HOME_DIR="$(getent passwd $USER | awk -F ':' '{print $6}')"

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
        if [[ -d "$HOME_DIR/.config/adept" ]]
        then
            # check the script's "default" path
            KEY_PATH="$HOME_DIR/.config/adept"
        else
            echo "!!!    WARNING: no ADEPT keys detected (argument \$2, or \"$HOME_DIR/.config/adept\")."
            echo "!!!    Launching interactive terminal for credentials creation (device activation). Run this:"
            echo ""
            echo " > adept_activate --random-serial \\"
            echo "       --username {USERNAME} \\"
            echo "       --password {PASSWORD} \\"
            echo "       --output-dir files/adept"
            echo ""
            echo "!!!     (*) use --anonymous in place of --username, --password if you do not have an ADE account."
            echo "!!!     (*) credentials will be saved in the following path: \"$(pwd)/adept\""
        fi
    fi
fi

# *.acsm file not specified, or specified file doesn't exist
if [[ -z "$ACSM_FILE" ]] || [[ ! -f "$ACSM_FILE" ]]
then
    echo ""
    echo "!!!    WARNING: no ACSM file detected (argument \$1)."
    echo "!!!    Launching interactive terminal for manual loan management. Example commands below:"
    echo ""
    echo " > acsmdownloader \\"
    echo "       --adept-directory .adept \\"
    echo "       --output-file encrypted_file.drm \\"
    echo "       \"files/{ACSM_FILE}\""
    echo " > adept_remove \\"
    echo "       --adept-directory .adept \\"
    echo "       --output-dir files \\"
    echo "       --output-file \"{OUTPUT_FILE}\" \\"
    echo "       encrypted_file.drm"
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
        echo "> acsmdownloader --adept-directory .adept --output-file encrypted_file.drm \"files/$ACSM_FILE\""
        echo "> adept_remove --adept-directory .adept --output-dir files --output-file \"{OUTPUT_FILE}\" encrypted_file.drm"
        docker run \
            -v "$(pwd)":/home/libgourou/files \
            -v "$KEY_PATH":/home/libgourou/.adept \
            --rm bcliang/docker-libgourou \
            $ACSM_FILE
    fi
fi

