BioBuilds 2017.05 was released on 31 May 2017. This release updates 19 packages and adds 23 packages, including ABySS, Canu, Infernal, and Prokka. For further details, refer to "[Application in BioBuilds 2017.05](#applications-in-biobuilds-201705)" table below.

This release also introduces the "**biobuilds-opt**" package for Linux on x86\_64 and Linux on POWER, which installs the "opt" [feature](https://conda.io/docs/building/meta-yaml.html#id2) into your BioBuilds (conda) environment. This feature will preferentially install "alternative" versions of select tools built using the hardware vendor's development toolchain ([Intel Parallel Studio XE](https://software.intel.com/en-us/intel-parallel-studio-xe) for x86\_64 and [IBM Advance Toolchain 10.0](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation) for POWER), which in most cases, provide better performance than their counterparts built using the standard `gcc`-based toolchain.

If you encounter issues running a BioBuilds application, please feel free to either [create an issue in GitHub](https://github.com/lab7/biobuilds/issues) or email bug reports to [support@biobuilds.org](mailto:support@biobuilds.org).

### Table of Contents
* [Minimum Requirements](#minimum-requirements)
* [Installation](#installation)
* [Other Notes](#other-notes)
* [Application in BioBuilds 2017.05](#applications-in-biobuilds-201705)
* [Known Issues](#known-issues)


# Minimum Requirements

BioBuilds 2017.05 runs on macOS/OS X on x86\_64, Linux on x86\_64, and Linux on POWER. Approximately 3.7-GB of disk space is needed for a full BioBuilds installation.

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
    - If you plan on using BioBuilds tools with the `opt` feature enabled (i.e., installing the "biobuilds-opt" conda package), you *must* have the `advance-toolchain-at10.0-runtime` and `advance-toolchain-at10.0-mcore-libs` system packages (i.e., `rpm` or `deb`) installed on your system. Please refer to the "[Advance Toolchain Installation](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W51a7ffcf4dfd_4b40_9d82_446ebc23c550/page/IBM%20Advance%20Toolchain%20for%20PowerLinux%20Documentation?section=installation)" documentation for details on how to install these packages for your Linux distribution.

Several applications within the BioBuilds package have their own specific requirements. Please refer to the "[Other Notes](#other-notes)" section below for details.


# Installation

## Install miniconda

**NOTE**: If you are already have an existing BioBuilds 2015.11 or later installation, or are otherwise already using Continuum's [Miniconda](http://conda.pydata.org/miniconda.html) or [Anaconda](http://docs.continuum.io/anaconda/index) package manager, you can skip this part of the BioBuilds installation procedure.

To install BioBuilds 2017.05, please first download the appropriate Miniconda installer from Continuum Analytics:

* [OS X on x86\_64](https://repo.continuum.io/miniconda/Miniconda2-4.3.14-MacOSX-x86_64.sh)
* [Linux on x86\_64](https://repo.continuum.io/miniconda/Miniconda2-4.3.14-Linux-x86_64.sh)
* [Linux on POWER](https://repo.continuum.io/miniconda/Miniconda2-4.3.14-Linux-ppc64le.sh)

Then install Miniconda by running `bash Miniconda-latest-<os>-<arch>.sh`, where `<os>` is either "Linux" or "MacOSX", and `<arch>` is either "x86\_64" or "ppc64le"; for further details, refer to the [Conda Quick Install Guide](http://conda.pydata.org/docs/install/quick.html).

## Install the BioBuilds conda package

**Existing BioBuilds and/or conda users**: Before running the rest of the installation, you should first upgrade `conda` itself by running `conda update -y conda`; failing to do so may cause the BioBuilds install commands below to fail with with various `AssertionError` exceptions.

---

Once miniconda has been installed, you can then install BioBuilds 2017.05 by running:
```bash
conda create -c biobuilds -p /path/to/biobuilds-2017.05 biobuilds=2017.05 biobuilds-opt
```
You can then run BioBuilds applications by supplying their full path (i.e., `/path/to/biobuilds-2017.05/bin/<app>`), or simply by name after adding the `bin` directory to your `$PATH` environment variable (e.g., adding `export PATH="/path/to/biobuilds-2017.05/bin:$PATH"` to your `~/.bash_profile`, then running `<app>` in your BASH shell).

The above command will install the "opt"-enabled versions of various tools, if available. If, for some reason, you prefer _not_ to use "opt"-enabled tools, simply omit the "biobuilds-opt" package from the `conda create` command; i.e.,
```bash
conda create -c biobuilds -p /path/to/biobuilds-2017.05 biobuilds=2017.05
```

---

**Note**: the above installation procedure does _not_ create a standard Conda environment. If you would like to install and use BioBuilds 2017.05 like any other Conda environment, you should instead run:
```bash
conda create -c biobuilds -n biobuilds-2017.05 biobuilds=2017.05 biobuilds-opt
```
This will create a Conda environment called `biobuilds-2017.05`, which you can then use standard Conda commands to manipulate; e.g., `source activate biobuilds-2017.05` and `source deactivate` to enable or disable BioBuilds applications in your $PATH, respectively. Refer to the Conda "[Managing Environments](http://conda.pydata.org/docs/using/envs.html)" documentation for more details.

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

# Applications in BioBuilds 2017.05

The following table lists applications included in the BioBuilds 2017.05 release; note that for brevity, certain support libraries and dependent packages (e.g., individual Perl or R packages) are not listed.

| Application             | Version             | Changes since 2016.11   |
|-------------------------|---------------------|-------------------------|
| ABySS                   | 2.0.2               | New                     |
| ALLPATHS-LG             | 52488               | No change (Linux only)  |
| ARAGORN                 | 1.2.38              | New                     |
| bamkit                  | 16.07.26            | No change               |
| BAMtools                | 2.4.1               | Upgrade                 |
| Barracuda               | 0.7.107e            | No change (Linux only)  |
| bcftools                | 1.3.1               | "opt"-enabled [1]       |
| BEAST                   | 2.4.6               | New                     |
| bedops                  | 2.4.26              | Upgrade                 |
| bedtools                | 2.26.0              | "opt"-enabled           |
| Bfast                   | 0.7.0a              | "opt"-enabled           |
| Bioconductor            | 3.4                 | No change               |
| BioPerl                 | 1.6.924             | No change               |
| BioPython               | 1.69                | Upgrade                 |
| Boost                   | 1.62.0              | No change               |
| Bowtie                  | 1.1.2               | No change               |
| Bowtie2                 | 2.3.1               | Upgrade                 |
| BreakDancer             | 1.4.5               | No change               |
| BWA                     | 0.7.15              | "opt"-enabled           |
| Canu                    | 1.5                 | New                     |
| chimerascan             | 0.4.5a              | No change               |
| CLARK                   | 1.2.3.1             | New                     |
| Clustal Omega           | 1.2.4               | New                     |
| ClustalW                | 2.1                 | "opt"-enabled           |
| conda                   | >= 4.3.14           | Upgraded, as needed [2] |
| conifer                 | 0.2.2               | New                     |
| Cufflinks               | 2.2.1               | No change               |
| cutadapt                | 1.13                | Upgrade                 |
| DELLY2                  | 0.7.6               | No change               |
| DIAMOND                 | 0.8.24              | No change               |
| drFAST                  | 1.0.0.0             | New                     |
| EBSEQ (Bioconductor)    | 1.14.0              | No change               |
| EMBOSS                  | 6.6.0               | No change               |
| FASTA                   | 36.3.8e             | "opt"-enabled           |
| FASTQC                  | 0.11.5              | No change               |
| FASTX-Toolkit           | 0.0.14              | "opt"-enabled           |
| FreeBayes               | 1.1.0               | Upgrade                 |
| GCTA                    | 1.26.0              | New                     |
| GenomonFisher           | 0.2.0               | No change               |
| gnuplot                 | 5.0.0               | No change               |
| Graphviz                | 2.38.0              | No change               |
| HISAT2                  | 2.0.5               | New                     |
| HMMER                   | 3.1b2               | No change               |
| HTSeq                   | 0.6.1               | No change               |
| htslib                  | 1.3.2               | "opt"-enabled           |
| IGV                     | 2.3.93              | Upgrade                 |
| Infernal                | 1.1.2               | New                     |
| iSAAC                   | 03.16.09.21         | No change (Linux only)  |
| Kraken                  | 0.10.5_beta         | "opt"-enabled           |
| Lighter                 | 1.1.1               | New                     |
| LoFreq\*                | 2.1.2               | "opt"-enabled           |
| LUMPY-SV                | 0.2.13              | "opt"-enabled           |
| Matplotlib              | 1.5.3               | No change               |
| Mothur                  | 1.39.5              | Upgrade                 |
| MrBayes                 | 3.2.6               | No change               |
| mrFAST                  | 2.6.1.0             | New                     |
| mrsFAST                 | 3.4.0               | New                     |
| MUSCLE                  | 3.8.31              | "opt"-enabled           |
| NCBI BLAST+             | 2.6.0               | Upgrade                 |
| NovelSeq                | 1.0.2               | New                     |
| NumPy                   | 1.12.1              | Upgrade                 |
| Oases                   | 0.2.8               | "opt"-enabled           |
| OpenBLAS                | 0.2.19              | No change               |
| Pandas                  | 0.20.1              | Upgrade                 |
| parallel                | 20160922            | No change               |
| Parasight               | 7.6                 | New (Linux only)        |
| Perl                    | 5.22.0              | No change               |
| PHYLIP                  | 3.696               | No change               |
| Picard                  | 2.9.2               | Upgrade                 |
| Pindel                  | 0.2.5b8             | "opt"-enabled           |
| PLINK                   | 1.07                | "opt"-enabled           |
| PLINK-NG                | 1.90b3.42           | No change               |
| Primer3                 | 2.3.7               | "opt"-enabled           |
| Prodigal                | 2.6.3               | New                     |
| Prokka                  | 1.12                | New                     |
| Pysam                   | 0.8.4               | No change               |
| Python                  | 2.7.13              | Upgrade                 |
| R                       | 3.3.2               | No change               |
| R cowplot               | 0.7.0               | No change               |
| R tidyverse             | 1.0.0               | No change               |
| RAxML                   | 8.2.9               | No change               |
| RSEM                    | 1.3.0               | "opt"-enabled           |
| Sailfish                | 0.10.0              | No change               |
| Salmon                  | 0.7.2               | No change               |
| Sambamba                | 0.6.6               | New                     |
| SAMBLASTER              | 0.1.24              | Upgrade                 |
| Samtools                | 1.3.1               | "opt"-enabled           |
| scalpel                 | 0.5.3               | "opt"-enabled           |
| scikit-bio              | 0.4.2               | No change               |
| SciPy                   | 0.19.0              | Upgrade                 |
| Seqtk                   | 1.2.94              | "opt"-enabled           |
| SHRiMP                  | 2.2.3               | "opt"-enabled           |
| SNAP                    | 1.0beta.18          | New                     |
| Snippy                  | 3.0                 | New                     |
| SnpEff                  | 4.3o                | Upgrade                 |
| SnpSift                 | 4.3o                | Upgrade                 |
| SOAP3-DP                | r177                | No change (Linux only)  |
| SOAPaligner             | 2.20                | "opt"-enabled           |
| SOAPbuilder             | 2.20                | "opt"-enabled           |
| SOAPdenovo2             | 2.4.240             | "opt"-enabled           |
| SPAdes                  | 3.10.1              | Upgrade                 |
| SplazerS                | 1.3.3               | No change               |
| SQLite                  | 3.13.0              | No change               |
| SRA Tools               | >= 2.8.0            | Upgraded, as needed [3] |
| STAR                    | 2.5.2b              | No change               |
| STAR-fusion             | 0.8.0               | No change               |
| T-Coffee                | 11.00.8cbe486       | "opt"-enabled           |
| tabix                   | 1.3.2               | "opt"-enabled           |
| tassel                  | 5.2.37              | Upgrade                 |
| tbl2asn                 | 25.3                | New                     |
| TMAP                    | 3.4.0               | "opt"-enabled           |
| TopHat                  | 2.1.1               | "opt"-enabled           |
| Trimmomatic             | 0.36                | No change               |
| Trinity                 | 2.2.0               | No change               |
| variant_tools           | 2.7.0               | No change               |
| vcflib                  | 1.0.0_rc1_16.05.18  | New                     |
| vcftools                | 0.1.14              | No change               |
| Velvet                  | 1.2.10              | "opt"-enabled           |

[1] '"opt"-enabled' means the conda package was rebuilt using the hardware vendor's toolchain for additional performance improvements, even though the (upstream) version was not changed since the 2016.11 release.

[2] "conda" is the package manager used by BioBuilds and may be upgraded by its provider ([Continuum Analytics](https://www.continuum.io)) as necessary. The version listed here (4.3.14) was the most current when BioBuilds 2017.05 was released, but BioBuilds should work with any newer version of `conda`.

[3] The "SRA Tools" package is marked as "Upgraded, as needed", since updates may be provided through the "biobuilds" conda channel to ensure protocol and/or format compatiblity with the NCBI SRA server.


# Known issues

- Because of its reliance on packages built using pre-2.0 versions of `conda-build`, you may not be able install BioBuilds into prefixes (i.e., file system locations) with names longer than 80 characters.
