#!/bin/bash

abort() {
    echo "FATAL: ${1:-unknown error}" >&2
    exit 1
}

[ -f "/src/bb-build-flags.env" ] || \
    abort "Could not find BioBuilds sources in /src"

# "--shell" option to drop into an interactive shell instead of immediately
# running "conda build"; this is particularly useful for recipe debugging.
shell=0
for arg in "$@"; do
    if [ "$arg" == "--shell" ]; then
        shell=1
        break
    fi
done

cd "/src"
source bb-build-flags.env ${BB_MAKE_JOBS:-1}

# If requested, drop to an interactive shell instead running "conda build"
if [ $shell -eq 1 ]; then
    exec /bin/bash -i
fi

CONDA_PLATFORM=`conda info | grep -i 'platform :' | awk '{print $3;}'`

# Now that "conda build" creates environments in $CONDA_BLD_PATH, we need to
# avoid using "/src/conda-bld" as the build root directory; doing so would
# force us to use expensive file copies when creating build environments, as
# cross-device hard links aren't supported and symlinks breaks things like gcc.
export CONDA_BLD_PATH=/tmp/conda-bld
mkdir -p "${CONDA_BLD_PATH}"

# Make the host's source cache avilable to reduce network traffic
[ -d /src/conda-bld/src_cache ] && \
    ln -sfn /src/conda-bld/src_cache "${CONDA_BLD_PATH}/src_cache"

# Use local copies of existing BioBuilds packages to reduce network traffic
if [ -d "/src/conda-bld/${CONDA_PLATFORM}" -o -d "/src/conda-bld/noarch" ]; then
    channel_opts="-c file:///src/conda-bld"
else
    channel_opts=
fi


# conda sometimes tries to write in the install root's (/opt/miniconda) "pkgs"
# or "envs" sub-directories, or tries to hard link to files within them, which
# can trigger hard-to-diagnose failures if the container is run as a non-root
# user (i.e., started with the "docker run" "-u" option). Since it's not clear
# which packages trigger such behavior enough to provide another workaround,
# run "conda build" as "root" using the container's "local" filesystem (see
# above comments for the reasons why), copy the built packages into the correct
# "/src/conda-bld" subdirectory, then call chown to "fix" the files' ownership.
DEST_UID=`stat -c '%u' /src`
DEST_GID=`stat -c '%g' /src`

set -e -x
touch /tmp/build_timestamp
conda build $channel_opts $@

for d in ${CONDA_PLATFORM} noarch; do
    src_dir="${CONDA_BLD_PATH}/${d}"
    dest_dir="/src/conda-bld/${d}"

    if [ ! -d "$dest_dir" ]; then
        mkdir -p "/src/conda-bld/${d}"
        chown ${DEST_UID}:${DEST_GID} "/src/conda-bld/${d}"
    fi

    # Use "find" instead of globbing to prevent script failure in case no
    # package files were placed inside this ${src_dir}.
    find ${src_dir} -type f -name '*.tar.bz2' | \
        xargs --no-run-if-empty -I% cp -pv % ${dest_dir}

    conda index ${dest_dir}

    find "${dest_dir}" -type f -newer /tmp/build_timestamp | \
        xargs --no-run-if-empty chown ${DEST_UID}:${DEST_GID}
done

if [ -d /src/conda-bld/src_cache ]; then
    find /src/conda-bld/src_cache -type f -uid $UID | \
        xargs --no-run-if-empty chown ${DEST_UID}:${DEST_GID}
fi
