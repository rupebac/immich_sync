#!/bin/bash
url=$(cat ~/.cloudbox_url)
username=$(cat ~/.cloudbox_username)
password=$(cat ~/.cloudbox_pwd)
USER=$(whoami)
owncloudcmd -u "${username}" -p "${password}" --non-interactive "/mnt/cloudclone/immich_upload/${USER}" "${url}" /immich
