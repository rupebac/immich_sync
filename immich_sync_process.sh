#!/bin/bash
#SCRIPT_DIR=$(dirname "$(realpath "$0")")
SCRIPT_DIR=$(dirname "$0")
cd $(dirname "$0")
SCRIPT_DIR=$(pwd)
USER=$(whoami)
USERNAME=$(cat ~/.cloudbox_username)
UPLOAD_DIR="/mnt/cloudclone/immich_upload/$USER"

LOCK_FILE="$SCRIPT_DIR/${USERNAME}.lock"

# Function to clean up and exit
cleanup_exit() {
    echo "Exiting..."
    ./immich_upload_refresh.sh
    rm -f "$LOCK_FILE"
    exit 1
}

# Catch Ctrl+C and call the cleanup_exit function
trap cleanup_exit SIGINT

# Check if the lock file exists
if [ -e "$LOCK_FILE" ]; then
    echo "Previous instance is still running. Exiting."
    exit 1
fi
# Create a lock file
touch "$LOCK_FILE"


./immich_upload_refresh.sh > ./logs/${USER}/refresh.log
./immich_iteration.sh ${USER} ${UPLOAD_DIR} > ./logs/${USER}/sync.log 2>> ./logs/${USER}/sync_errors.log
./immich_upload_refresh.sh >> ./logs/${USER}/refresh.log
cat ./logs/${USER}/sync.log
cat ./logs/${USER}/sync_errors.log

rm -f "$LOCK_FILE"
