BioBuilds 2017.11 was released on 5 December 2017. This release updates 22 packages and adds 12 packages, including 20/20+, jellyfish, and kallisto. For further details, refer to "[Application in BioBuilds 2017.11](#applications-in-biobuilds-201711)" table below.

This release includes the "**biobuilds-opt**" package for Linux on x86\_64 and Linux on POWER originally introduced in the 2017.05 release.  This package adds the "opt" [feature](https://conda.io/docs/building/meta-yaml.html#id2) into your BioBuilds `conda` environment, which then causes the `conda` package manager to preferentially install "alternative" builds of selected built using the hardware vendor's development toolchain ([Intel Parallel Studio XE](https://software.intel.com/en-us/intel-parallel-studio-xe) for x86\_64 and [IBM Advance Toolchain 10.0](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation) for POWER). In most cases, such builds provide better performance than their counterparts built using the standard `gcc`-based toolchain.

This release also marks the start of our migration to building packages using the [Anaconda 5 toolchains](https://www.anaconda.com/blog/developer-blog/utilizing-the-new-compilers-in-anaconda-distribution-5/) rather than OS-supplied ones. This switch lets us make use of newer compiler capabilities, particularly with regards to performance and security, while keeping support for older operating systems (e.g., CentOS/RedHat 6). It also allows us to reduce the need on external (i.e., OS-provided) dependencies, such as X11 shared libraries.

If you encounter issues running a BioBuilds application, please feel free to either [create an issue in GitHub](https://github.com/lab7/biobuilds/issues) or email bug reports to [support@biobuilds.org](mailto:support@biobuilds.org).

### Table of Contents
* [Minimum Requirements](#minimum-requirements)
* [Installation](#installation)
* [Other Notes](#other-notes)
* [Application in BioBuilds 2017.11](#applications-in-biobuilds-201711)
* [Known Issues](#known-issues)


# Minimum Requirements

BioBuilds 2017.11 runs on macOS/OS X on x86\_64, Linux on x86\_64, and Linux on POWER. Approximately 4.5-GB of disk space is needed for a full BioBuilds installation.

Please note that BioBuilds packages have been built with more aggressive compiler optimizations, and target more recent processor architectures and operating system releases, than most other Anaconda packages. If you are attempting to run BioBuilds on architectures and/or operating systems older than what is listed below, some or all of the included binaries might not function correctly:

- **OS X on x86\_64**:
    - Nehalem or later microarchitecture required. If your CPU was manufactured before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
    - OS X 10.9 (Mavericks) or later required. OS X 10.8 (Mountain Lion) and below have effectively reached end-of-life as of October 2015, and are not officially supported as BioBuilds host operating systems.
- **Linux on x86\_64**:
    - Nehalem or later microarchitecture required. If your CPU was manufactured before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
    - glibc 2.12 or later required. Most recent Linux distributions for x86\_64 (including Debian 7 and later, Ubuntu 12.04 and later, and CentOS/RHEL 6 and later) meet this minimum and are supported. *Note, however, that CentOS/RHEL 5 and distributions based on them run glibc 2.5 and therefore are not supported.*
- **Linux on POWER**:
    - POWER8 or later, running in little-endian mode required. Support for big-endian and/or POWER7 systems has been dropped as of the 2015.11 release; if you need to run one or more BioBuilds applications on such systems, please [contact Lab7 Systems](mailto:info@lab7.io) about a paid support contract.
    - glibc 2.17 or later required. Currently, Ubuntu 14.04.2 LTS, Ubuntu 16.04 LTS, and RedHat Enterprise Linux (RHEL) 7 are supported.
    - If you plan on using BioBuilds tools with the `opt` feature enabled (i.e., installing the "biobuilds-opt" conda package), you *must* have the `advance-toolchain-at10.0-runtime` and `advance-toolchain-at10.0-mcore-libs` system (i.e., `rpm` or `deb`) packages installed on your system. Please refer to the "[Advance Toolchain Installation](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation?section=installation)" documentation for details on how to install these packages for your Linux distribution.

Several applications within the BioBuilds package have their own specific requirements. Please refer to the "[Other Notes](#other-notes)" section below for details.


# Installation

## Install miniconda

**NOTE**: If you are already have an existing BioBuilds 2015.11 or later installation, or are otherwise already using the `conda` package manager, you can skip this part of the BioBuilds installation procedure.

To install BioBuilds 2017.11, please first download the appropriate Miniconda installer from Anaconda:

* [OS X on x86\_64](https://repo.continuum.io/miniconda/Miniconda2-4.3.27-MacOSX-x86_64.sh)
* [Linux on x86\_64](https://repo.continuum.io/miniconda/Miniconda2-4.3.27-Linux-x86_64.sh)
* [Linux on POWER](https://repo.continuum.io/miniconda/Miniconda2-4.3.27-Linux-ppc64le.sh)

Then install Miniconda by running `bash Miniconda-latest-<os>-<arch>.sh`, where `<os>` is either "Linux" or "MacOSX", and `<arch>` is either "x86\_64" or "ppc64le"; for further details, refer to the [Conda Quick Install Guide](http://conda.pydata.org/docs/install/quick.html).

## Install the BioBuilds conda package

**Existing BioBuilds and/or conda users**: Before running the rest of the installation, you should first upgrade `conda` itself by running `conda update -y conda`; failing to do so may cause the BioBuilds install commands below to fail.

**Linux on POWER (linux-ppc64le) users**: If you intend to install the `biobuilds-opt` package and/or other BioBuilds tools with additional optimizations (i.e., the "opt"-feature) enabled, you *must* have the `advance-toolchain-at10.0-runtime` and `advance-toolchain-at10.0-mcore-libs` system (i.e., `rpm` or `deb`) packages installed on your system. Please refer to the "[Advance Toolchain Installation](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation?section=installation)" documentation for details on how to install these packages for your Linux distribution.

---

Once miniconda has been installed, you can then install BioBuilds 2017.11 by running:
```bash
conda create -c biobuilds -p /path/to/biobuilds-2017.11 biobuilds=2017.11 biobuilds-opt
```
You can then run BioBuilds applications by supplying their full path (i.e., `/path/to/biobuilds-2017.11/bin/<app>`), or simply by name after adding the `bin` directory to your `$PATH` environment variable (e.g., adding `export PATH="/path/to/biobuilds-2017.11/bin:$PATH"` to your `~/.bash_profile`, then running `<app>` in your BASH shell).

The above command will install the "opt"-feature versions of various tools, if available. If, for some reason, you prefer _not_ to use "opt"-feature tools, simply omit the "biobuilds-opt" package from the `conda create` command; i.e.,
```bash
conda create -c biobuilds -p /path/to/biobuilds-2017.11 biobuilds=2017.11
```

---

**Note**: the above installation procedure does _not_ create a standard Conda environment. If you would like to install and use BioBuilds 2017.11 like any other Conda environment, you should instead run:
```bash
conda create -c biobuilds -n biobuilds-2017.11 biobuilds=2017.11 biobuilds-opt
```
This will create a Conda environment called `biobuilds-2017.11`, which you can then use standard Conda commands to manipulate; e.g., `source activate biobuilds-2017.11` and `source deactivate` to enable or disable BioBuilds applications in your $PATH, respectively. Refer to the Conda "[Managing Environments](http://conda.pydata.org/docs/using/envs.html)" documentation for more details.

---

Since BioBuilds packages are available through an [Anaconda.org channel](https://anaconda.org/biobuilds), you can also use `conda` to create and use custom installations (environments) that contain only a subset of the BioBuilds applications. For example, if you need just `bwa` and `samtools`, you could create a custom environment using:
```bash
conda create -c biobuilds -n my-bifx biobuilds-opt bwa samtools
# ... OR (if you'd rather not use the "opt"-enabled versions) ...
conda create -c biobuilds -n my-bifx bwa samtools
```
This will install only `bwa`, `samtools`, and any needed dependencies into `/path/to/miniconda/envs/my-bifx/bin`, without any of the other BioBuilds applications that you do not intend to use (e.g., ALLPATHS-LG or EMBOSS). You can then run these applications either by using their full path, by running `source activate my-bifx` to dynamically add them to your current shell `$PATH`, or by "permanently" adding `/path/to/miniconda/envs/my-bifx/bin` to your $PATH in your `~/.bash_profile` file.

The `-c biobuilds` option in the above commands instruct `conda` to search the BioBuilds Anaconda channel for packages. You can avoid having to provide that option with every `conda` command by adding the BioBuilds channel to your `~/.condarc` file, like so:
```yaml
channels:
  - biobuilds
  - defaults
```
Doing so makes it much easier to create a collection of Conda environments, each tailored to the bioinformatics you intend to do; e.g.,
```bash
conda create -n basic-bifx biobuilds-opt blast emboss
conda create -n rnaseq-bifx biobuilds-opt trinity cufflinks tophat
```
Refer to Continuum's "[Using conda](http://conda.pydata.org/docs/using/index.html)" documentation for more details on using Conda to manage various run-time environments.

---

**Note**: if you plan to install BioBuilds on a different file system (i.e., mount point) than Miniconda/Anaconda, you may want to prevent `conda` from creating softlinks (symlinks) either by setting the global `allow_softlinks` option to `False` (e.g., by running `conda config --set allow_softlinks false`) or by using the `conda create` `copy` option when installing BioBuilds (i.e., `conda create --copy <other install options>`). This helps avoid symlink-related issues that can prevent applications from correctly finding components like shared libraries or Perl/Python/R modules. Note that either of this options will significantly increase the amount of disk space used by the BioBuilds installation.


# Other notes

While every effort has been made to make BioBuilds as self-contained as possible, various applications still require external libraries and interpreters be installed on the system. If these dependencies are currently not available on your system, you will need either `sudo` access or system administrator help to install them before you can run these applications.

- Linux users on both x86\_64 and POWER (ppc64le) will need libX11, libXrender, and libXext to run many of the applications that produce graphical or image output (e.g., R or matplotlib). These can be installed by running `sudo apt-get install libx11-6 libxrender1 libxext6` on Debian/Ubuntu-based systems or `sudo yum install libX11 libXrender libXext` on CentOS/RedHat-based systems.
- Linux on POWER users will also need libffi and the GCC runtime libraries on their systems. These can be installed by running `sudo apt-get install libffi6 gcc g++ gfortran` on Ubuntu 14.04 or `sudo yum install libffi gcc gcc-g++ gcc-gfortran` on RedHat 7.
- Linux on POWER users who want to use "opt"-feature tools must have the `advance-toolchain-at10.0-runtime` and `advance-toolchain-at10.0-mcore-libs` system packages (i.e., `rpm` or `deb`) installed on your system. Please refer to the "[Advance Toolchain Installation](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation?section=installation)" for details.
- A few applications, including IGV, Trinity, and Picard, require a Java Runtime Environment (JRE) be installed and accessible through your `$PATH`. The JRE can either be the "official" [Oracle JRE](https://www.java.com/en/download/manual.jsp) or the OpenJDK JRE provided by many distribution vendors. In either case, the JRE must support Java 8 or above.
- The SOAP3-DP and Barracuda applications are GPU-accelerated applications, and therefore, require that the appropriate nVidia hardware and [drivers](http://www.nvidia.com/Download/index.aspx?lang=en-us) (including libcuda.so) be installed on your system.
- Some applications may see performance benefits from specific hardware configurations. In particular, the POWER version of the Illumina aligner (iSAAC) has better performance on hardware running in SMT4 or SMT8 mode, with the application's `-j` option set to the appropriate number of hardware threads.

# Applications in BioBuilds 2017.11

The following table lists applications included in the BioBuilds 2017.11 release; note that for brevity, certain support libraries and dependent packages (e.g., individual Perl or R packages) are not listed.

| Application             | Version               | Changes since 2017.05   |
|-------------------------|-----------------------|-------------------------|
| 20/20+                  | 1.1.3                 | New                     |
| ABySS                   | 2.0.2                 | No change               |
| ALLPATHS-LG             | 52488                 | No change (Linux only)  |
| ARAGORN                 | 1.2.38                | No change               |
| bamkit                  | 16.07.26              | No change               |
| BAMstats                | 1.25                  | New                     |
| BAMtools                | 2.4.1                 | No change               |
| Barracuda               | 0.7.107e              | No change (Linux only)  |
| bcftools                | 1.6.0                 | Upgrade                 |
| BEAST                   | 2.4.6                 | No change               |
| bedops                  | 2.4.26                | No change               |
| bedtools                | 2.26.0                | No change               |
| Bfast                   | 0.7.0a                | No change               |
| Bioconductor            | 3.6                   | Upgrade                 |
| BioPerl                 | 1.6.924               | No change               |
| BioPython               | 1.70                  | Upgrade                 |
| Boost                   | 1.62.0                | No change               |
| Bowtie                  | 1.1.2                 | No change               |
| Bowtie2                 | 2.3.1                 | No change               |
| BreakDancer             | 1.4.5                 | No change               |
| BWA                     | 0.7.17                | Upgrade                 |
| Canu                    | 1.5                   | No change               |
| cgpVcf                  | 2.2.0                 | New                     |
| chimerascan             | 0.4.5a                | No change               |
| CLARK                   | 1.2.3.1               | No change               |
| Clustal Omega           | 1.2.4                 | No change               |
| ClustalW                | 2.1                   | No change               |
| conifer                 | 0.2.2                 | No change               |
| Cufflinks               | 2.2.1                 | No change               |
| cutadapt                | 1.13                  | No change               |
| DELLY2                  | 0.7.6                 | No change               |
| DIAMOND                 | 0.8.24                | No change               |
| drFAST                  | 1.0.0.0               | No change               |
| EBSEQ (Bioconductor)    | 1.18.0                | Upgrade                 |
| EMBOSS                  | 6.6.0                 | No change               |
| FASTA                   | 36.3.8e               | No change               |
| FASTQC                  | 0.11.5                | No change               |
| FASTX-Toolkit           | 0.0.14                | No change               |
| FreeBayes               | 1.1.0                 | No change               |
| GCTA                    | 1.26.0                | No change               |
| GenomonFisher           | 0.2.0                 | No change               |
| gnuplot                 | 5.2.2                 | Upgrade                 |
| HISAT2                  | 2.0.5                 | No change               |
| HMMER                   | 3.1b2                 | No change               |
| HTSeq                   | 0.6.1                 | No change               |
| htslib                  | 1.6.0                 | Upgrade                 |
| IGV                     | 2.3.93                | No change               |
| Infernal                | 1.1.2                 | No change               |
| iSAAC                   | 04.17.09.06           | Upgrade                 |
| jellyfish               | 2.2.7                 | New                     |
| kallisto                | 0.43.1                | New                     |
| kmergenie               | 1.7044                | New                     |
| Kraken                  | 0.10.5\_beta          | No change               |
| Lighter                 | 1.1.1                 | No change               |
| LoFreq\*                | 2.1.2                 | No change               |
| LUMPY-SV                | 0.2.13                | No change               |
| Matplotlib              | 1.5.3                 | No change               |
| migrate                 | 3.6.11                | New                     |
| Mothur                  | 1.39.5                | No change               |
| MrBayes                 | 3.2.6                 | No change               |
| mrFAST                  | 2.6.1.0               | No change               |
| mrsFAST                 | 3.4.0                 | No change               |
| MUSCLE                  | 3.8.31                | No change               |
| NCBI BLAST+             | 2.6.0                 | No change               |
| NovelSeq                | 1.0.2                 | No change               |
| NumPy                   | 1.13.3                | Upgrade                 |
| Oases                   | 0.2.8                 | No change               |
| OpenBLAS                | 0.2.20                | Upgrade                 |
| Pandas                  | 0.21.0                | Upgrade                 |
| parallel                | 20160922              | No change               |
| Parasight               | 7.6                   | No change               |
| Perl                    | 5.22.0                | No change               |
| PHYLIP                  | 3.696                 | No change               |
| Picard                  | 2.15.0                | Upgrade                 |
| Pindel                  | 0.2.5b8               | No change               |
| PLINK                   | 1.07                  | No change               |
| PLINK-NG                | 1.90b3.42             | No change               |
| Primer3                 | 2.3.7                 | No change               |
| Probabilistic 20/20     | 1.2.0                 | New                     |
| Prodigal                | 2.6.3                 | No change               |
| Prokka                  | 1.12                  | No change               |
| Pysam                   | 0.8.4                 | No change               |
| Python                  | 2.7.13                | No change               |
| R                       | 3.4.2                 | Upgrade                 |
| R cowplot               | 0.9.1                 | Upgrade                 |
| R ggplot2               | 2.2.1                 | Upgrade                 |
| R rio                   | 0.5.5                 | New                     |
| R sequenza              | 2.1.2                 | New                     |
| R tidyverse             | 1.2.1                 | Upgrade                 |
| RAxML                   | 8.2.9                 | No change               |
| RSEM                    | 1.3.0                 | No change               |
| Sailfish                | 0.10.0                | No change               |
| Salmon                  | 0.7.2                 | No change               |
| Sambamba                | 0.6.6                 | No change               |
| SAMBLASTER              | 0.1.24                | No change               |
| Samtools                | 1.6.0                 | Upgrade                 |
| scalpel                 | 0.5.3                 | No change               |
| scikit-bio              | 0.4.2                 | No change               |
| scikit-learn            | 0.19.1                | New                     |
| SciPy                   | 1.0.0                 | Upgrade                 |
| Seqtk                   | 1.2.94                | No change               |
| SGA                     | 0.10.15               | New                     |
| SHRiMP                  | 2.2.3                 | No change               |
| SNAP                    | 1.0beta.18            | No change               |
| Snippy                  | 3.0                   | No change               |
| SnpEff                  | 4.3t                  | Upgrade                 |
| SnpSift                 | 4.3t                  | Upgrade                 |
| SOAP3-DP                | r177                  | No change (Linux only)  |
| SOAPaligner             | 2.20                  | No change               |
| SOAPbuilder             | 2.20                  | No change               |
| SOAPdenovo2             | 2.4.240               | No change               |
| SPAdes                  | 3.10.1                | No change               |
| SplazerS                | 1.3.3                 | No change               |
| SQLite                  | 3.13.0                | No change               |
| SRA Tools               | >= 2.8.0              | Upgraded, as needed [1] |
| STAR                    | 2.5.2b                | No change               |
| STAR-fusion             | 0.8.0                 | No change               |
| T-Coffee                | 11.00.8cbe486         | No change               |
| tabix                   | 1.6.0                 | Upgrade                 |
| tassel                  | 5.2.37                | No change               |
| tbl2asn                 | 25.3                  | No change               |
| TMAP                    | 3.4.0                 | No change               |
| TopHat                  | 2.1.1                 | No change               |
| Trimmomatic             | 0.36                  | No change               |
| Trinity                 | 2.2.0                 | No change               |
| variant\_tools          | 2.7.0                 | No change               |
| vcflib                  | 1.0.0\_rc1\_16.05.18  | No change               |
| vcftools                | 0.1.15                | Upgrade                 |
| Velvet                  | 1.2.10                | No change               |

[1] The "SRA Tools" package is marked as "Upgraded, as needed", since updates may be provided through the "biobuilds" conda channel to ensure protocol and/or format compatiblity with the NCBI SRA server.


# Known issues

- Because of its reliance on packages built using pre-2.0 versions of `conda-build`, you may not be able install BioBuilds into prefixes (i.e., file system locations) with names longer than 80 characters.
