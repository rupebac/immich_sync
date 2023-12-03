#!/bin/bash
# The motivation of this script is to run this under a cron job, that scans a folder for new files to import, sort of like an upload folder.
# so every processed file is delete. I am aiming to use this in order to integrate Immich with OCIS.


IMAGE_EXTS="jpg jpeg png gif bmp tiff tif svg webp psd cr2 crw nef raw dng"

# Video extensions

VIDEO_EXTS="avi 3gp mp4 mov mkv wmv flv mpg mpeg rm swf vob divx m4v"

# ----------------------------------------------------------------------------------


USER=$1
DIR=$2

SCRIPT_DIR=$(dirname "$(realpath "$0")")

LOCK_FILE="$SCRIPT_DIR/${USER}.lock"

echo "LockFile $LOCK_FILE"

# Function to clean up and exit
cleanup_exit() {
    echo "Exiting..."
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


EXTENSIONS="$IMAGE_EXTS $VIDEO_EXTS"


echo "Scanning for $USER in $DIR for files in $EXTENSIONS"

# Iterate files
find "$DIR" -type f -print0 | while IFS= read -r -d '' FILE; do
  EXTENSION="${FILE##*.}"  # Get the file extension
  EXTENSION_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')  # Convert extension to lowercase

  # Convert all extensions to lowercase for comparison
  EXTENSIONS_LOWER=$(echo "$EXTENSIONS" | tr '[:upper:]' '[:lower:]')

  if echo "$EXTENSIONS_LOWER" | grep -qw "$EXTENSION_LOWER"; then

    echo "==> $FILE"

    # Execute external program
    sudo -u "$USER" immich upload "$FILE"

    CMD_STATUS=$?

    if [ $CMD_STATUS -eq 0 ]; then
       rm "$FILE"
    else
       mv "$FILE" "$DIR/../errors/$USER"
    fi

  fi
done

# Remove the lock file when done
rm -f "$LOCK_FILE"
