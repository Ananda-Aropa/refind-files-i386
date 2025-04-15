#!/bin/bash

echo "deb http://http.us.debian.org/debian unstable main contrib non-free" | sudo tee /etc/apt/sources.list

cat <<EOF | sudo tee /etc/apt/apt.conf.d/999norecommend
APT::Install-Recommends "0";
APT::Install-Suggests "0";
APT::AllowUnauthenticated "true";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

sudo dpkg --add-architecture i386
sudo apt download refind:i386

upstream_version=$(ls refind_*.deb | awk -F '_' '{print $2}')

sed -i -r "s/refind-files-i386 \([0-9]+(\.[0-9]+)+-[0-9]+(\.[0-9]+)?/refind-files-i386 ($upstream_version/g" debian/changelog

dpkg-deb -x ls refind_*.deb refind