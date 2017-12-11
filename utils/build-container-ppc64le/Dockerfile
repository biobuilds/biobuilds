FROM ppc64le/centos:7
MAINTAINER BioBuilds Support <support@biobuilds.org>

# Install "lsb_release" script. Also available through the "redhat-lsb-core"
# package, but that would force us to install other things we don't need.
COPY lsb_release /usr/bin/lsb_release

# Make sure a basic set of command line tools are available
RUN yum update -y && yum install -y \
        bzip2 \
        curl \
        file \
        findutils \
        gawk \
        grep \
        gzip \
        hostname \
        openssl \
        sed \
        tar \
        unzip \
        wget \
        which \
        xz \
    && yum clean all

# Install a basic set of build tools (compilers, make, patch, etc.) from the
# official CentOS repository as well as Continuum Analytics' conda for use as
# a supplemental package manager. (Conda saves us the trouble of having to
# maintain our own tarballs and/or RPM repositories in case we want/need to
# install newer versions of other build tools.)
RUN yum update -y && yum install -y \
        bison \
        chrpath \
        cvs \
        flex \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        git \
        glibc-static \
        libstdc++-static \
        make \
        mercurial \
        nasm \
        patch \
        perl \
        pkgconfig \
        svn \
        vim-common \
    && yum clean all \
    && curl -o /tmp/miniconda.sh \
        "https://repo.continuum.io/miniconda/Miniconda2-4.3.27-Linux-ppc64le.sh" \
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

# Install a minimal set of X11 development packages from the official CentOS
# repository; these are needed for building conda packages that depend on the
# cairo vector graphics library (among other things).
RUN yum update -y && yum install -y \
        libX11-devel \
        libXext-devel \
        libXrender-devel \
        libXt-devel \
    && yum clean all

# Install the CUDA compiler (nvcc). Note that a "functional" libcuda.so (i.e.,
# driver runtime library) is *not* actually needed to build GPU applications as
# the CUDA toolkit contains a stub version which can be used by the linker.
RUN rpm -Uvh "http://developer.download.nvidia.com/compute/cuda/repos/rhel7/ppc64le/cuda-repo-rhel7-7.5-23.ppc64le.rpm" \
    && yum install -y cuda-minimal-build-7-5 \
    && ln -sfn /usr/local/cuda-7.5 /usr/local/cuda \
    && yum clean all
ENV PATH /usr/local/cuda/bin:$PATH

# Configure things so non-root users can use conda in this container
ENV HOME /tmp
RUN echo 'channels: ["biobuilds", "defaults"]' > /tmp/.condarc && \
    echo 'show_channel_urls: True' >> /tmp/.condarc && \
    echo 'update_dependencies: False' >> /tmp/.condarc && \
    echo 'anaconda_upload: False' >> /tmp/.condarc && \
    chmod 444 /tmp/.condarc

# Entrypoint script so BioBuilds packages can be built by running:
# "docker run -v /path/to/repo:/src biobuilds/build-ppc64le <pkg>"
COPY conda-build.sh /
ENTRYPOINT ["/conda-build.sh"]

# Install "conda-build" from the Anaconda "defaults" channel.
# NOTE: Doing this in two phases (i.e., update "conda" first, then install
#       "conda-build") to avoid potential problems (e.g., unable to find the
#       desired "conda-build" package) caused by having too big a jump from
#       the existing to the desired versions of "conda".
# NOTE: Pin conda & conda-build versions to match what's available on ppc64le.
RUN /opt/miniconda/bin/conda install --yes --quiet \
        --override-channels -c defaults \
        conda==4.3.27 \
    && echo 'conda ==4.3.27' > /opt/miniconda/conda-meta/pinned \
    && /opt/miniconda/bin/conda install --yes --quiet \
        --override-channels -c defaults \
        conda-build==3.0.28 anaconda-client \
    && echo 'conda-build ==3.0.28' >> /opt/miniconda/conda-meta/pinned \
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
