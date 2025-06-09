#!/bin/bash 

scriptPath=$(readlink -f $(dirname "$0"))
ReladestinationPath="/finished"
destinationPath="${scriptPath}${ReladestinationPath}"

if [ ! -d "$destinationPath" ]; then
	set -e
	mkdir -p "$destinationPath"
	set +e
fi

#transmission-remote localhost:9091 -n admin:password -t "${TR_TORRENT_ID}" --move "${destinationPath}"
transmission-remote localhost:9091 -t "${TR_TORRENT_ID}" --move "${destinationPath}"


