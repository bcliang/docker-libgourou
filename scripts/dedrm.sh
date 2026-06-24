#!/bin/bash -e

ACSM_FILE=$1
KEY_PATH=$2
HOME_DIR="$(getent passwd "$USER" | awk -F ':' '{print $6}')"
IMAGE="bcliang/docker-libgourou"

# Pick a container runtime. Honor $CONTAINER_RUNTIME, else auto-detect the first
# available docker-compatible CLI. $CONTAINER_RUNTIME accepts any such CLI.
RUNTIME="${CONTAINER_RUNTIME:docker}"


# Docker needs a well-defined path for mounting volumes (paths should start with
# /* or ./*). Normalize $KEY_PATH to an absolute path, or fall back to the
# default config location when it is omitted.
if [[ -n "$KEY_PATH" && -d "$KEY_PATH" ]]; then
    case $KEY_PATH in
        /*) ;;                                       # absolute path, leave as-is
        ~*) KEY_PATH="$HOME_DIR/${KEY_PATH:1}" ;;    # home directory
        *)  KEY_PATH="$(pwd)/$KEY_PATH" ;;           # relative path
    esac
elif [[ -z "$KEY_PATH" ]]; then
    if [[ -d "$HOME_DIR/.config/adept" ]]; then
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

# Warn when no usable *.acsm file was provided.
if [[ -z "$ACSM_FILE" || ! -f "$ACSM_FILE" ]]; then
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

# Always mount the working directory; mount the ADEPT keys when available.
docker_args=(-v "$(pwd)":/home/libgourou/files)
[[ -n "$KEY_PATH" ]] && docker_args+=(-v "$KEY_PATH":/home/libgourou/.adept)

if [[ -n "$KEY_PATH" && -n "$ACSM_FILE" && -f "$ACSM_FILE" ]]; then
    # ADEPT keys and a valid *.acsm file: run the automated download + de-DRM
    echo "> acsmdownloader --adept-directory .adept --output-file encrypted_file.drm \"files/$ACSM_FILE\""
    echo "> adept_remove --adept-directory .adept --output-dir files --output-file \"{OUTPUT_FILE}\" encrypted_file.drm"
    "$RUNTIME" run "${docker_args[@]}" --rm "$IMAGE" "$ACSM_FILE"
else
    # missing keys or *.acsm file: drop into an interactive shell
    echo -e "\nMounted Volumes"
    echo -e "   $(pwd) --> /home/libgourou/files/"
    [[ -n "$KEY_PATH" ]] && echo -e "   $KEY_PATH --> /home/libgourou/.adept/"
    echo ""
    "$RUNTIME" run "${docker_args[@]}" -it --entrypoint /bin/bash --rm "$IMAGE"
fi
