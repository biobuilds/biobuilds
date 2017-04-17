FROM centos:6
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
        net-tools \
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
RUN yum install -y \
        bison \
        chrpath \
        cvs \
        flex \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        git \
        glibc-static \
        libffi-devel \
        libstdc++-static \
        make \
        mercurial \
        nasm \
        patch \
        perl \
        svn \
        vim-common \
    && yum clean all && \
    curl -o /tmp/miniconda.sh \
        "http://download.lab7.io/Miniconda-3.16.0-Linux-x86_64.sh" && \
    /bin/bash /tmp/miniconda.sh -f -b -p /opt/miniconda && \
    # GNU `tar` ignore root's umask by default, so we need to forcibly remove
    # non-root write permissions from the extracted files. Not doing this can
    # cause `conda` to fail in strange ways when running this image with
    # `docker run -u $UID`. In such cases, the user's primary GID will be 0
    # (root), and `conda` assumes that hard links will work if a package's
    # "index.json" has the group write permission set; however, if some file
    # within a package does *NOT* have group write permissions, hard linking
    # will silently fail, leading to an incomplete package installation within
    # the target conda environment.
    chmod -R go-w /opt/miniconda && \
    /opt/miniconda/bin/conda clean --packages --tarballs --source-cache --yes && \
    rm -f /tmp/miniconda.sh
ENV PATH /opt/miniconda/bin:$PATH

# Install a minimal set of X11 development packages from the official CentOS
# repository; these are needed for building conda packages that depend on the
# cairo vector graphics library (among other things).
RUN yum install -y \
        libX11-devel \
        libXext-devel \
        libXrender-devel \
        libXt-devel \
    && yum clean all

# Install the CUDA compiler (nvcc). Note that a "functional" libcuda.so (i.e.,
# driver runtime library) is *not* actually needed to build GPU applications as
# the CUDA toolkit contains a stub version which can be used by the linker.
RUN rpm -Uvh "http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-7.0-28.x86_64.rpm" && \
    yum install -y cuda-minimal-build-7-0 && \
    ln -sfn /usr/local/cuda-7.0 /usr/local/cuda && \
    yum clean all
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
# NOTE: "biobuilds" channel needed to get updates for linux-ppc64le that may
#       not yet be available in the "defaults" channel.
# NOTE: Pin conda & conda-build versions to match what's available on ppc64le.
RUN /opt/miniconda/bin/conda install --yes --quiet \
        --override-channels -c biobuilds -c defaults \
        'conda==4.3.16' 'conda-build==2.1.9' 'anaconda-client' \
    && echo 'conda ==4.3.16' > /opt/miniconda/conda-meta/pinned \
    && echo 'conda-build ==2.1.9' >> /opt/miniconda/conda-meta/pinned \
    # See comments above for why this `chmod` is needed
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

# Additional build tools present in the build image used for the 2015.11 and
# 2016.04 releases; as of the 2016.11 release, we will replace these with their
# Anaconda equivalents (i.e., as dependencies in the recipe "meta.yaml" files).
#RUN yum install -y \
#        autoconf automake libtool cmake readline-devel readline-static && \
#    yum clean all
