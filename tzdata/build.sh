#!/bin/bash
export LANG=C LC_ALL=C

TZBASE="${PREFIX}/share/zoneinfo"

# Users should contact us, rather than IANA, to report bugs in our timezone
# data package; we will "escalate" any such reports as necessary.
export BUGEMAIL='<https://github.com/biobuilds/biobuilds/issues>' \

TIMEZONES='
africa
antarctica
asia
australasia
backward
etcetera
europe
factory
northamerica
pacificnew
southamerica
systemv
'

# Build and install useful timezone utilities
make -e zic zdump
install -d -m 755 "${PREFIX}/bin"
install -m 755 zic zdump "${PREFIX}/bin"

# Supply two versions of the timezone/DST data:
# - the "posix" version based on Coordinated Universal Time (UTC)
# - the "right" version based on International Atomic Time (TAI)
install -d -m 755 "${TZBASE}-posix"
install -d -m 755 "${TZBASE}-right"

# Directory containing the default timezone/DST data. Most systems set their
# hardware clocks based on the UTC (POSIX) standard, so that's our default.
install -d -m 755 "${TZBASE}"

# Avoid deprecation warnings re: zic's `-y` argument
cp -p yearistype.sh yearistype
chmod +x yearistype

# Generate the timezone/DST data files
for zone in ${TIMEZONES}; do
    ./zic -d "${TZBASE}" -L /dev/null ${zone}
    ./zic -d "${TZBASE}-posix" -L /dev/null   ${zone}
    ./zic -d "${TZBASE}-right" -L leapseconds ${zone}
done

# Generate a posixrules file
./zic -d "${TZBASE}" -p America/New_York

# Install additional informational files
install -m 644 *.tab *.list "${TZBASE}"

# TODO (?): Replace any hard links that may have been generated in the install
# directories with symlinks. Because of how our current build system is
# configured, we already get this behavior rather by accident, but for the sake
# of reproducibility, we should find a way to make this happen consistently.
