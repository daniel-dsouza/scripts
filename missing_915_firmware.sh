#!/usr/bin/env bash

# search apt logs for missing firmware
RESULTS=$(zgrep "W: Possible missing firmware /lib/firmware/i915/.* for module i915" /var/log/apt/term* | grep -o "i915.*\.bin" | awk '!a[$0]++')

for FIRMWARE in $RESULTS
do
  FIRMWARE_LOCATION="/lib/firmware/${FIRMWARE}"

  # check if firmware exists.
  if [ ! -f "$FIRMWARE_LOCATION" ]
  then
    echo "Could not find ${FIRMWARE_LOCATION}. Downloading."

    # Download firmware from git.kernel.org
    FIRMWARE_URL="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/${FIRMWARE}"
    FIRMWARE_DOWNLOAD="/tmp/${FIRMWARE}"
    DOWNLOAD_RESULT=$(curl -f "$FIRMWARE_URL" --create-dirs -o "$FIRMWARE_DOWNLOAD")
    
    # Copy the file int /lib/firmware
    if [ $? -eq 0 ]
    then
      sudo mv "${FIRMWARE_DOWNLOAD}" "${FIRMWARE_LOCATION}"
    else
      echo "Could not download ${FIRMWARE_URL}"
    fi
  else
    echo "${FIRMWARE_LOCATION} exists. Skipping."
  fi
done
