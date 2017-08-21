#!/bin/bash

set -e

RASPBIAN_IMAGE=${K8_PI_CLUSTER_IMAGE:-"http://director.downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-08-17/2017-08-16-raspbian-stretch-lite.zip"}

if [[ ! -x /usr/local/etcher-cli/etcher ]]; then
    echo "* Installing etcher"
    brew cask install etcher
fi

if [ ! -d "${PWD}/raspbian-image" ]; then
    echo "* Downloading Raspbian image"
    mkdir "${PWD}/raspbian-image"
    curl -o "${PWD}/raspbian-image/image.zip" "${RASPBIAN_IMAGE}"
    cd raspbian-image && tar -xvf image.zip && rm image.zip ;
fi

# Find the SD card
echo "* Searching for SD-card"
SD_CARD_DISK=$(diskutil list | grep -B 2 15.9 | head -n 1 | awk '{print $1}')

if [ -z "${SD_CARD_DISK}" ]; then
    echo "Unable to locate SD-card"
    exit 5
fi

echo "* SD-card found"
echo "${SD_CARD_DISK}"

echo "* Flashing Raspbian on SD-card"
/usr/local/etcher-cli/etcher /snapshot/etcher/dist/Etcher-cli-1.1.2-darwin-x64-app/lib/cli/etcher.js -y --no-unmount -d "${SD_CARD_DISK}" "${PWD}/raspbian-image/2017-08-16-raspbian-stretch-lite.img"

echo "* Configuring image"

echo "* Configuring GPU memory"
echo " " >> /Volumes/boot/config.txt
echo "# Setting GPU mempory limit to 16mb since running headless"
echo "gpu_mem=16" >> /Volumes/boot/config.txt

echo "* Enabling SSH"
touch /Volumes/boot/ssh

echo "* Unmounting SD-card"
diskutil unmountDisk "${SD_CARD_DISK}"

echo "Done!"
