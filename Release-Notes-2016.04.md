BioBuilds 2016.04 was released on 11 April 2016.

The most significant change for this release has been updates to 21 packages and the addition of 25 new packages, including BioPerl and NCBI SRA Tools. For further details, refer to "[Application in BioBuilds 2016.04](#applications-in-biobuilds-201604)" table below.

If you encounter any bugs running a BioBuilds application, please send feel free to send bugs reports to [bugs@biobuilds.org](mailto:bugs@biobuilds.org) or [create a issue](https://github.com/lab7/biobuilds/issues) in the GitHub repository.


# Minimum Requirements

BioBuilds 2016.04 runs on OS X on x86_64, Linux on x86_64, and Linux for POWER8. Approximately 2.5-GB of disk space is needed for a full installation of BioBuilds.

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

## Install miniconda

**NOTE**: If you are already have an existing BioBuilds 2015.11 distribution or are otherwise already using Continuum's [Miniconda](http://conda.pydata.org/miniconda.html) or [Anaconda](http://docs.continuum.io/anaconda/index) system, you can skip this part of the BioBuilds installation procedure.

To install BioBuilds 2016.04, please first download the appropriate Miniconda installer from Continuum Analytics:

* [OS X on x86_64](https://repo.continuum.io/miniconda/Miniconda-3.16.0-MacOSX-x86_64.sh)
* [Linux on x86_64](https://repo.continuum.io/miniconda/Miniconda-3.16.0-Linux-x86_64.sh)
* [Linux on POWER8](https://repo.continuum.io/miniconda/Miniconda-3.16.0-Linux-ppc64le.sh)

Then install Miniconda by running `bash Miniconda-latest-<os>-<arch>.sh`, where `<os>` is either "Linux" or "MacOSX", and `<arch>` is either "x86_64" or "ppc64le"; for further details, refer to the [Conda Quick Install Guide](http://conda.pydata.org/docs/install/quick.html).

## Install the BioBuilds conda package

**Existing BioBuilds and/or conda users**: Before running the rest of the installation, you *must* first upgrade `conda` itself by running `conda update -c biobuilds -c defaults -y conda`; failing to do so may cause the BioBuilds install commands below to fail with with various `AssertionError` exceptions.

---

Once miniconda has been installed, you can then install BioBuilds 2016.04 by running:
```bash
conda create -c biobuilds -p /path/to/biobuilds-2016.04 biobuilds=2016.04
```
You can then run BioBuilds applications by supplying their full path (i.e., `/path/to/biobuilds-2016.04/bin/<app>`), or simply by name after adding the `bin` directory to your `$PATH` environment variable (i.e., adding `export PATH="/path/to/biobuilds-2016.04/bin:$PATH"` to your `~/.bash_profile`, then running `<app>` in your BASH shell).

---

**Note**: the above installation procedure does _not_ create a standard Conda environment. If you would like to install and use BioBuilds 2016.04 like any other Conda environment, you should instead run:
```bash
conda create -c biobuilds -n biobuilds-2016.04 biobuilds=2016.04
```
This will create a Conda environment called `biobuilds-2016.04`, which you can then use standard Conda commands to manipulate; e.g., `source activate biobuilds-2016.04` and `source deactivate` to enable or disable BioBuilds applications in your $PATH, respectively. Refer to the Conda "[Managing Environments](http://conda.pydata.org/docs/using/envs.html)" documentation for more details.

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

- Linux on POWER8 (ppc64le) users will need libffi and the GCC runtime libraries on their systems. These can be installed by running `sudo apt-get install libffi6 gcc g++ gfortran` on Ubuntu 14.04 or `sudo yum install libffi gcc gcc-g++ gcc-gfortran` on RedHat 7.
- Linux users on both x86_64 and ppc64le will need libX11, libXrender, and libXext to run many of the applications that produce graphical or image output (e.g., R or matplotlib). These can be installed by running `sudo apt-get install libx11-6 libxrender1 libxext6` on Debian/Ubuntu-based systems or `sudo yum install libX11 libXrender libXext` on CentOS/RedHat-based systems.
- A few applications, including IGV, Trinity, and Picard, require a Java Runtime Environment (JRE) be installed and accessible through your $PATH. The JRE can either be the "official" [Oracle JRE](https://www.java.com/en/download/manual.jsp) or the OpenJDK JRE provided by many distribution vendors. In either case, the JRE must support Java 8 or above.
- The SOAP3-DP and Barracuda applications are GPU-accelerated applications, and therefore, require that the appropriate nVidia hardware and [drivers](http://www.nvidia.com/Download/index.aspx?lang=en-us) (including libcuda.so) be installed on your system.


# Applications in BioBuilds 2016.04

The following table lists applications included in the BioBuilds 2016.04 release; note that for brevity, certain support libraries and dependent packages (e.g., individual R packages) are not listed.

| Application   | Version       | Changes since 2015.11   |
|---------------|---------------|-------------------------|
| ALLPATHS-LG   | 52488         | No change (Linux only)  |
| BAMtools      | 2.4.0         | No change               |
| Barracuda     | 0.7.107e      | Upgrade (Linux only)    |
| bcftools      | 1.3.0         | New                     |
| bedtools      | 2.25.0        | No change               |
| Bfast         | 0.7.0a        | No change               |
| Bioconductor  | 3.2           | No change               |
| BioPerl       | 1.6.924       | New                     |
| BioPython     | 1.66          | No change               |
| Boost         | 1.54.0        | No change               |
| Bowtie        | 1.1.2         | No change               |
| Bowtie2       | 2.2.8         | Upgrade                 |
| BreakDancer   | 1.4.5         | New                     |
| BWA           | 0.7.13        | Upgrade                 |
| chimerascan   | 0.4.5a        | New                     |
| ClustalW      | 2.1           | No change               |
| Cufflinks     | 2.2.1         | No change               |
| DELLY2        | 0.7.2         | New                     |
| EBSEQ (R)     | 1.10.0        | No change               |
| EMBOSS        | 6.5.7         | No change               |
| FASTA         | 36.3.8c       | Upgrade                 |
| FASTQC        | 0.11.5        | Upgrade                 |
| FASTX-Toolkit | 0.0.14        | New                     |
| FreeBayes     | 1.0.2         | New                     |
| GenomonFisher | 0.1.1         | New                     |
| gnuplot       | 5.0.0         | No change               |
| Graphviz      | 2.38.0        | No change               |
| HMMER         | 3.1b2         | No change               |
| HTSeq         | 0.6.1         | No change               |
| htslib        | 1.3.0         | Upgrade                 |
| IGV           | 2.3.72        | Upgrade                 |
| iSAAC         | 15.04.01      | No change (Linux only)  |
| LoFreq*       | 2.1.2         | New                     |
| Matplotlib    | 1.5.1         | Upgrade                 |
| Mothur        | 1.36.1        | No change               |
| MrBayes       | 3.2.6         | New                     |
| MUSCLE        | 3.8.31        | New                     |
| NCBI BLAST+   | 2.3.0         | Upgrade                 |
| NumPy         | 1.10.4        | Upgrade                 |
| Oases         | 0.2.8         | No change               |
| Pandas        | 0.18.0        | New                     |
| Perl          | 5.22.0        | New                     |
| PHYLIP        | 3.696         | New                     |
| Picard        | 2.1.1         | Upgrade                 |
| Pindel        | 0.2.5b8       | New                     |
| PLINK         | 1.07          | No change               |
| Pysam         | 0.8.4         | Upgrade                 |
| Python        | 2.7.11        | Upgrade                 |
| R             | 3.2.2         | No change               |
| RSEM          | 1.2.29        | Upgrade                 |
| Sailfish      | 0.9.0         | New                     |
| Samtools      | 1.3.0         | Upgrade                 |
| scalpel       | 0.5.3         | New                     |
| SciPy         | 0.17.0        | New                     |
| SHRiMP        | 2.2.3         | No change               |
| SnpEff        | 4.2           | New                     |
| SnpSift       | 4.2           | New                     |
| SOAP3-DP      | r177          | No change (Linux only)  |
| SOAPaligner   | 2.20          | No change               |
| SOAPbuilder   | 2.20          | No change               |
| SOAPdenovo2   | 2.4.240       | No change               |
| SplazerS      | 1.3.3         | New                     |
| SQLite        | 3.9.2         | Upgrade                 |
| SRA Tools     | Variable      | New                     |
| STAR          | 2.5.1b        | Upgrade                 |
| STAR-fusion   | 0.7.0         | New                     |
| tabix         | 1.3.0         | Upgrade                 |
| tassel        | 5.2.22        | New                     |
| T-Coffee      | 11.00.8cbe486 | New                     |
| TMAP          | 3.4.0         | No change               |
| TopHat        | 2.1.1         | Upgrade                 |
| Trinity       | 2.2.0         | Upgrade                 |
| variant_tools | 2.7.0         | Upgrade                 |
| Velvet        | 1.2.10        | No change               |

**Note**: The "SRA Tools" package version is marked as "Variable" since updates may be made available through the "biobuilds" conda channel to help ensure protocol and/or format compatiblity with the NCBI SRA server.
