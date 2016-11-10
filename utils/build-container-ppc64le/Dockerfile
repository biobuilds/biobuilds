FROM ppc64le/ubuntu:14.04
MAINTAINER BioBuilds Support <support@biobuilds.org>

# Make sure a basic set of command line tools are available
RUN apt-get update && apt-get -y -q dist-upgrade && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        debianutils \
        file \
        findutils \
        gawk \
        grep \
        gzip \
        hostname \
        lsb-release \
        openssl \
        sed \
        tar \
        unzip \
        wget \
        xz-utils \
    && apt-get clean

# Install a basic set of build tools (compilers, make, patch, etc.) from the
# official CentOS repository as well as Continuum Analytics' conda for use as
# a supplemental package manager. (Conda saves us the trouble of having to
# maintain our own tarballs and/or RPM repositories in case we want/need to
# install newer versions of other build tools.)
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        bison \
        chrpath \
        cvs \
        flex \
        g++ \
        gcc \
        gfortran \
        git \
        libffi-dev \
        make \
        mercurial \
        nasm \
        patch \
        perl \
        pkg-config \
        subversion \
        vim-common \
    && apt-get clean \
    && curl -o /tmp/miniconda.sh \
        "http://download.lab7.io/devops/Miniconda-3.16.0-Linux-ppc64le.sh" \
    && /bin/bash /tmp/miniconda.sh -f -b -p /opt/miniconda \
    # GNU `tar` ignore root's umask by default, so we need to forcibly remove
    # non-root write permissions from the extracted files. Not doing this can
    # cause `conda` to fail in strange ways when running this image with
    # `docker run -u $UID`. In such cases, the user's primary GID will be 0
    # (root), and `conda` assumes that hard links will work if a package's
    # "index.json" has the group write permission set; however, if some file
    # within a package does *NOT* have group write permissions, hard linking
    # will silently fail, leading to an incomplete package installation within
    # the target conda environment.
    && chmod -R go-w /opt/miniconda \
    && /opt/miniconda/bin/conda clean --packages --tarballs --source-cache --yes \
    && rm -f /tmp/miniconda.sh

ENV PATH /opt/miniconda/bin:$PATH

# Install a minimal set of X11 development packages from the official Ubuntu
# repository; these are needed for building conda packages that depend on the
# cairo vector graphics library (among other things).
RUN apt-get update && apt-get install --no-install-recommends -q -y \
        libx11-dev \
        libxext-dev \
        libxrender-dev \
        libxt-dev \
    && apt-get clean

# Install the CUDA compiler (nvcc). Note that a "functional" libcuda.so (i.e.,
# driver runtime library) is *not* actually needed to build GPU applications as
# the CUDA toolkit contains a stub version which can be used by the linker.
RUN cd /tmp && wget -q 'http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/ppc64el/cuda-repo-ubuntu1404_7.0-28_ppc64el.deb' \
    && dpkg -i cuda-repo-ubuntu1404_7.0-28_ppc64el.deb \
    && rm -f /tmp/cuda-repo-ubuntu1404_7.0-28_ppc64el.deb \
    && apt-get update \
    && apt-get install -y -q --no-install-recommends \
        cuda-core-7-0 \
        cuda-cudart-dev-7-0 \
    && apt-get clean \
    && ln -sfn /usr/local/cuda-7.0 /usr/local/cuda
ENV PATH /usr/local/cuda/bin:$PATH

# Configure things so non-root users can use conda in this container
ENV HOME /tmp
RUN echo 'channels: ["biobuilds", "defaults"]' > /tmp/.condarc && \
    echo 'show_channel_urls: True' >> /tmp/.condarc && \
    echo 'update_dependencies: False' >> /tmp/.condarc && \
    echo 'anaconda_upload: False' >> /tmp/.condarc && \
    chmod 444 /tmp/.condarc

# Entrypoint script so BioBuilds packages can be built by running:
# "docker run -v /path/to/repo:/src lab7io/build:biobuilds <pkg>"
COPY conda-build.sh /
ENTRYPOINT ["/conda-build.sh"]

# Install "conda-build" from the Anaconda "defaults" channel.
# NOTE: Pin conda & conda-build versions to match what's available on ppc64le.
RUN /opt/miniconda/bin/conda install --yes --quiet \
        'conda==4.2.12' 'conda-build==2.0.8' 'anaconda-client' \
    && echo 'conda ==4.2.12' > /opt/miniconda/conda-meta/pinned \
    && echo 'conda-build ==2.0.8' >> /opt/miniconda/conda-meta/pinned \
    # See above comments for why this `chmod` is needed
    && chmod -R go-w /opt/miniconda \
    # "conda build" now creates build environments in $CONDA_BLD_PATH instead
    # of "/tmp/.conda/envs" or "/opt/miniconda/envs"; since cross-device
    # hard-linking is not possible, conda decides to symlink instead. However,
    # symlinks break RPATH calculations (among other things), which in turn,
    # can cause things like `gcc` to fail horribly. To work around this, we
    # need to tell conda to copy files instead of symlinking, even though this
    # is a fairly expensive (i.e., slow) operation.
    && chmod u+w /tmp/.condarc \
    && echo 'allow_softlinks: False' >> /tmp/.condarc \
    && chmod u-w /tmp/.condarc \
    && /opt/miniconda/bin/conda clean --packages --tarballs --source-cache --yes

# "Additional" build tools present in the build image used for the 2015.11 and
# 2016.04 releases; for more "portable" builds, we eventually want to replace
# dependencies on these system-provided tools and libraries with dependencies
# on the equivalent conda-provided packages.
#RUN apt-get update && apt-get install --no-install-recommends -q -y \
#        autoconf \
#        automake \
#        libltdl-dev \
#        libtool \
#    && apt-get clean
