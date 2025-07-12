#!/bin/bash

set -e

cd "$(dirname "$0")"

DISTRO="${DISTRO:-unstable}"
MAINTAINER=$(git log -1 --pretty=format:'%an <%ae>')

echo "deb http://http.us.debian.org/debian unstable main contrib non-free" | sudo tee /etc/apt/sources.list

cat <<EOF | sudo tee /etc/apt/apt.conf.d/999norecommend
APT::Install-Recommends "0";
APT::Install-Suggests "0";
APT::AllowUnauthenticated "true";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

sudo dpkg --add-architecture i386
yes | sudo apt update -y --allow-unauthenticated

yes | sudo apt download -y --allow-unauthenticated refind:i386

VERSION=$(ls refind_*.deb | awk -F '_' '{print $2}')
REVISION=${REVISION:-0}

echo "v$VERSION" > ../VERSION
PACKAGE_NAME=$(grep 'Source:' control | awk '{print $2}')

# Gen changelog (from latest commit)
MSG=$(git log -1 --pretty=format:'%s')
DATE=$(git log -1 --pretty=format:'%ad' --date=format:'%a, %d %b %Y %H:%M:%S %z')

# Generate changelog
cat <<EOF >changelog
$PACKAGE_NAME ($VERSION-$REVISION) $DISTRO; urgency=medium

$(echo -e "$MSG" | sed -r 's/^/  * /g')

 -- $MAINTAINER  $DATE

EOF

dpkg-deb -x refind_*.deb ../refind

rm -f refind_*.deb