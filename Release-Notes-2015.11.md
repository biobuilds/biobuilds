BioBuilds 2015.11 was released on 23 November 2015.

The most significant change for this release has been the switch from a tarball-based installation process to using [Miniconda](http://conda.pydata.org/miniconda.html) from Continuum Analytics. We believe that this switch lets us keep the major benefits of the tarball (e.g., minimal installation complexity and self-contained environments), while adding functionality such as the ability to create custom BioBuilds "installs" (in case you don't need _all_ the tools that come with BioBuilds) and access to a broader ecosystem of other packages available through [anaconda.org](https://anaconda.org/).

In addition, we've opened up the process by which applications are built and added to BioBuilds. Conda recipes for every package included in BioBuilds are now available through the [BioBuilds GitHub repository](https://github.com/lab7/biobuilds), and we will gladly consider/accept any pull requests should you want to add your favorite application.

Please send bugs reports to [bugs@biobuilds.org](mailto:bugs@biobuilds.org) or [create a issue](https://github.com/lab7/biobuilds/issues) in the GitHub repository.


# Minimum Requirements

BioBuilds 2015.11 runs on OS X on x86_64, Linux on x86_64, and Linux for POWER8. Approximately 2.5-GB of disk space is needed for a full installation of BioBuilds.

Please note that BioBuilds packages have been built with more aggressive compiler optimizations, and target more recent processor architectures and operating system releases, than most other Anaconda packages. If you are attempting to run BioBuilds on architectures and/or operating systems older than what is listed below, some or all of the included binaries might not function correctly:

- OS X on x86_64:
  - Nehalem or later microarchitecture required. If your CPU was built before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
  - OS X 10.9 (Mavericks) or later required. OS X 10.8 (Mountain Lion) and below have effectively reached end-of-life as of October 2015, and are not officially supported as BioBuilds host operating systems.
- Linux on x86_64:
  - Nehalem or later microarchitecture required. If your CPU was built before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
  - glibc 2.12 or later required. Most recent Linux distributions for x86_64 (including Debian 7 and later, Ubuntu 12.04 and later, and CentOS/RHEL 6 and later) meet this minimum and are supported. *Note, however, that CentOS/RHEL 5 and distributions based on them run glibc 2.5 and therefore are not supported.*
- Linux on POWER:
  - POWER8 or later, running in little-endian mode required. Support for big-endian and/or POWER7 systems has been dropped as of this release; if you need to run one or more BioBuilds applications on such systems, please [contact Lab7 Systems](mailto:info@lab7.io) about a paid support contract.
  - glibc 2.17 or later required. Currently, both Ubuntu 14.04.2 and RedHat Enterprise Linux (RHEL) 7 are supported.

Several applications within the BioBuilds package have their own specific requirements. Please refer to the "[Other Notes](#other-notes)" section below for details.


# Install

To install BioBuilds 2015.11, please first download the appropriate Miniconda installer from Continuum Analytics:

* [OS X on x86_64](https://repo.continuum.io/miniconda/Miniconda-latest-MacOSX-x86_64.sh)
* [Linux on x86_64](https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh)
* [Linux on POWER8](http://repo.continuum.io/miniconda/Miniconda-latest-Linux-ppc64le.sh)

Then install Miniconda by running `bash Miniconda-latest-<os>-<arch>.sh`, where `<os>` is either "Linux" or "MacOSX", and `<arch>` is either "x86_64" or "ppc64le"; for further details, refer to the [Conda Quick Install Guide](http://conda.pydata.org/docs/install/quick.html). **NOTE**: If you are already using Continuum's [Miniconda](http://conda.pydata.org/miniconda.html) or [Anaconda](http://docs.continuum.io/anaconda/index) system, you can skip this part of the BioBuilds installation procedure.

**Linux on POWER8 (ppc64le) users**: Before running the rest of the installation, you *must* first upgrade `conda` itself by running `conda update -c biobuilds -y conda`; failing to do so will cause the install commands below to fail with an `AssertionError: emboss-6.5.7-0.tar.bz2 MatchSpec(u'libgd')` error.

Once miniconda has been installed, you can then install BioBuilds 2015.11 by running:
```bash
conda create -c biobuilds -p /path/to/biobuilds-2015.11 biobuilds=2015.11
```
You can then run BioBuilds applications by supplying their full path (i.e., `/path/to/biobuilds-2015.11/bin/<app>`), or simply by name after adding the `bin` directory to your `$PATH` environment variable (i.e., adding `export PATH="/path/to/biobuilds-2015.11/bin:$PATH"` to your `~/.bash_profile`, then running `<app>` in your BASH shell).

---

**Note**: the above installation procedure does _not_ create a standard Conda environment. If you would like to install and use BioBuilds 2015.11 like any other Conda environment, you should instead run:
```bash
conda create -c biobuilds -n biobuilds-2015.11 biobuilds=2015.11
```
This will create a Conda environment called `biobuilds-2015.11`, which you can then use standard Conda commands to manipulate; e.g., `source activate biobuilds-2015.11` and `source deactivate` to enable or disable BioBuilds applications in your $PATH, respectively. Refer to the Conda "[Managing Environments](http://conda.pydata.org/docs/using/envs.html)" documentation for more details.

(This procedure actually installs the BioBuilds environment into `/path/to/miniconda/envs/biobuilds-2015.11`, so you should be able to add `/path/to/miniconda/envs/biobuilds-2015.11/bin` to your $PATH and run BioBuilds applications without having to use the normal `source activate`/`source deactivate` procedure.)

---

Since BioBuilds packages are now available through an [Anaconda.org channel](https://anaconda.org/biobuilds), you can also use `conda` to create and use custom installations (environments) that contain only a subset of the BioBuilds applications. For example, if you need just `bowtie2` and `samtools`, you could create a custom environment using:
```bash
conda create -c biobuilds -n my-bifx bowtie2 samtools
```
This will install only `bowtie2`, `samtools`, and any needed dependencies into `/path/to/miniconda/envs/my-bifx/bin`, without any of the other BioBuilds applications that you do not intend to use (e.g., ALLPATHS-LG or EMBOSS). You can then run these applications either by using their full path, by running `source activate my-bifx` to dynamically add them to your current shell $PATH, or by "permanently" adding `/path/to/miniconda/envs/my-bifx/bin` to your $PATH in your `~/.bash_profile` file.

The `-c biobuilds` option in the above commands instruct `conda` to search the BioBuilds Anaconda channel for packages. You can avoid having to provide that option with every `conda` command by adding the BioBuilds channel to your `~/.condarc` file, like so:
```yaml
channels:
  - biobuilds
  - defaults
```
Doing so makes it much easier to create a collection of Conda environments, each tailored to the bioinformatics you intend to do; e.g.,
```bash
conda create -n basic-bifx blast emboss
conda create -n rnaseq-bifx trinity cufflinks tophat
```
Refer to Continuum's "[Using conda](http://conda.pydata.org/docs/using/index.html)" documentation for more details on using Conda to manage various run-time environments.


# Other notes

While every effort has been made to make BioBuilds as self-contained as possible, various applications still require external libraries and interpreters be installed on the system. If these dependencies are currently not available on your system, you will need either `sudo` access or system administrator help to install them before you can run these applications.

- Various applications include various Perl support scripts. Currently, an external Perl 5 interpreter must be available in your $PATH; on OS X and most Linux distributions, this should not be a major impediment as many system utilities already require Perl. **NOTE**: We intend to remove this dependency on the system Perl in the next release (BioBuilds 2016.04).
- Linux on POWER8 (ppc64le) users will need libffi and the GCC runtime libraries on their systems. These can be installed by running `sudo apt-get install libffi6 gcc g++ gfortran` on Ubuntu 14.04 or `sudo yum install libffi gcc gcc-g++ gcc-gfortran` on RedHat 7.
- Linux users on both x86_64 and ppc64le will need libX11, libXrender, and libXext to run many of the applications that produce graphical or image output (e.g., R or matplotlib). These can be installed by running `sudo apt-get install libx11-6 libxrender1 libxext6` on Debian/Ubuntu-based systems or `sudo yum install libX11 libXrender libXext` on CentOS/RedHat-based systems.
- A few applications, including IGV, Trinity, and Picard, require a Java Runtime Environment (JRE) be installed and accessible through your $PATH. The JRE can either be the "official" [Oracle JRE](https://www.java.com/en/download/manual.jsp) or the OpenJDK JRE provided by many distribution vendors. In either case, the JRE must support Java 7 or above.
- The SOAP3-DP and Barracuda applications are GPU-accelerated applications, and therefore, require the appropriate nVidia hardware, drivers, and CUDA shared libraries (libcuda.so) be installed. [Drivers](http://www.nvidia.com/Download/index.aspx?lang=en-us) and [CUDA shared libraries](https://developer.nvidia.com/cuda-downloads) are all available from the nVidia website.


# Applications in BioBuilds 2015.11

The following table lists applications included in the BioBuilds 2015.11 release; note that for brevity, certain support libraries and dependent packages (e.g., individual R packages) are not listed.

| Application   | Version   | New/Upgrade status      |
|---------------|-----------|-------------------------|
| ALLPATHS-LG   | 52488     | Upgrade (Linux only)    |
| BAMtools      | 2.4.0     | New                     |
| Barracuda     | 0.7.107b  | New (Linux only)        |
| bedtools      | 2.25.0    | Upgrade                 |
| Bfast         | 0.7.0a    | No change               |
| Bioconductor  | 3.2       | Upgrade                 |
| BioPython     | 1.66      | New                     |
| Boost         | 1.54.0    | No change               |
| Bowtie        | 1.1.2     | Upgrade                 |
| Bowtie2       | 2.2.6     | Upgrade                 |
| BWA           | 0.7.12    | Upgrade                 |
| ClustalW      | 2.1       | New                     |
| Cufflinks     | 2.2.1     | No change               |
| EBSEQ (R)     | 1.10.0    | New                     |
| EMBOSS        | 6.5.7     | New                     |
| FASTA         | 36.3.8b   | Upgrade                 |
| FastQC        | 0.11.4    | Upgrade                 |
| gnuplot       | 5.0.0     | New                     |
| Graphviz      | 2.38.0    | No change               |
| HMMER         | 3.1b2     | Upgrade                 |
| HTSeq         | 0.6.1     | No change               |
| htslib        | 1.2.1     | No change               |
| IGV           | 2.3.65    | Upgrade                 |
| iSAAC         | 15.04.01  | Upgrade (Linux only)    |
| Matplotlib    | 1.5.0     | New                     |
| Mothur        | 1.36.1    | Upgrade                 |
| NCBI BLAST+   | 2.2.31    | Upgrade (New on OS X)   |
| Numpy         | 1.9.2     | Upgrade                 |
| Oases         | 0.2.8     | New                     |
| Picard        | 1.140     | Upgrade                 |
| PLINK         | 1.07      | No change               |
| Pysam         | 0.8.3     | New                     |
| Python        | 2.7.10    | Upgrade                 |
| R             | 3.2.2     | Upgrade                 |
| RSEM          | 1.2.25    | New                     |
| Samtools      | 1.2.0     | Upgrade                 |
| SHRiMP        | 2.2.3     | No change (New on OS X) |
| SOAP3-DP      | r177      | No change (Linux only)  |
| SOAPaligner   | 2.20      | No change               |
| SOAPbuilder   | 2.20      | No change               |
| SOAPdenovo2   | 2.4.240   | No change (New on OS X) |
| SQLite        | 3.8.4.1   | No change               |
| STAR          | 2.4.2a    | Upgrade (New on OS X)   |
| tabix         | 1.2.1     | Upgrade                 |
| TMAP          | 3.4.0     | No change               |
| TopHat        | 2.1.0     | Upgrade                 |
| Trinity       | 2.1.1     | Upgrade (New on OS X)   |
| variant_tools | 2.6.3     | New                     |
| Velvet        | 1.2.10    | No change               |
