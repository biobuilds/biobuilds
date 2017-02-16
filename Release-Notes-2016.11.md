BioBuilds 2016.11 was released on 22 November 2016.

This release updates 36 packages and adds 19 packages, including LUMPY, PLINK-NG, RAxML, Salmon, and SPAdes. For further details, refer to "[Application in BioBuilds 2016.11](#applications-in-biobuilds-201611)" table below.

If you encounter any bugs running a BioBuilds application, please send feel free to send bugs reports to [bugs@biobuilds.org](mailto:bugs@biobuilds.org) or [create a issue](https://github.com/lab7/biobuilds/issues) in the GitHub repository.


# Minimum Requirements

BioBuilds 2016.11 runs on macOS/OS X on x86_64, Linux on x86_64, and Linux for POWER8. Approximately 3.5-GB of disk space is needed for a full BioBuilds installation.

Please note that BioBuilds packages have been built with more aggressive compiler optimizations, and target more recent processor architectures and operating system releases, than most other Anaconda packages. If you are attempting to run BioBuilds on architectures and/or operating systems older than what is listed below, some or all of the included binaries might not function correctly:

- OS X on x86_64:
  - Nehalem or later microarchitecture required. If your CPU was built before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
  - OS X 10.9 (Mavericks) or later required. OS X 10.8 (Mountain Lion) and below have effectively reached end-of-life as of October 2015, and are not officially supported as BioBuilds host operating systems.
- Linux on x86_64:
  - Nehalem or later microarchitecture required. If your CPU was built before ~2009 and does not support SSE4.x instructions, some BioBuilds applications may not start, and others may generate "illegal instruction" errors when running.
  - glibc 2.12 or later required. Most recent Linux distributions for x86_64 (including Debian 7 and later, Ubuntu 12.04 and later, and CentOS/RHEL 6 and later) meet this minimum and are supported. *Note, however, that CentOS/RHEL 5 and distributions based on them run glibc 2.5 and therefore are not supported.*
- Linux on POWER:
  - POWER8 or later, running in little-endian mode required. Support for big-endian and/or POWER7 systems has been dropped as of the 2015.11 release; if you need to run one or more BioBuilds applications on such systems, please [contact Lab7 Systems](mailto:info@lab7.io) about a paid support contract.
  - glibc 2.17 or later required. Currently, Ubuntu 14.04.2 LTS, Ubuntu 16.04 LTS, and RedHat Enterprise Linux (RHEL) 7 are supported.

Several applications within the BioBuilds package have their own specific requirements. Please refer to the "[Other Notes](#other-notes)" section below for details.


# Install

## Install miniconda

**NOTE**: If you are already have an existing BioBuilds 2015.11 or later installation, or are otherwise already using Continuum's [Miniconda](http://conda.pydata.org/miniconda.html) or [Anaconda](http://docs.continuum.io/anaconda/index) system, you can skip this part of the BioBuilds installation procedure.

To install BioBuilds 2016.11, please first download the appropriate Miniconda installer from Continuum Analytics:

* [OS X on x86_64](https://repo.continuum.io/miniconda/Miniconda2-4.2.12-MacOSX-x86_64.sh)
* [Linux on x86_64](https://repo.continuum.io/miniconda/Miniconda2-4.2.12-Linux-x86_64.sh)
* [Linux on POWER8](https://repo.continuum.io/miniconda/Miniconda2-4.2.12-Linux-ppc64le.sh)

Then install Miniconda by running `bash Miniconda-latest-<os>-<arch>.sh`, where `<os>` is either "Linux" or "MacOSX", and `<arch>` is either "x86_64" or "ppc64le"; for further details, refer to the [Conda Quick Install Guide](http://conda.pydata.org/docs/install/quick.html).

## Install the BioBuilds conda package

**Existing BioBuilds and/or conda users**: Before running the rest of the installation, you *must* first upgrade `conda` itself by running `conda update -c biobuilds -c defaults -y conda`; failing to do so may cause the BioBuilds install commands below to fail with with various `AssertionError` exceptions.

---

Once miniconda has been installed, you can then install BioBuilds 2016.11 by running:
```bash
conda create -c biobuilds -p /path/to/biobuilds-2016.11 biobuilds=2016.11
```
You can then run BioBuilds applications by supplying their full path (i.e., `/path/to/biobuilds-2016.11/bin/<app>`), or simply by name after adding the `bin` directory to your `$PATH` environment variable (i.e., adding `export PATH="/path/to/biobuilds-2016.11/bin:$PATH"` to your `~/.bash_profile`, then running `<app>` in your BASH shell).

---

**Note**: the above installation procedure does _not_ create a standard Conda environment. If you would like to install and use BioBuilds 2016.11 like any other Conda environment, you should instead run:
```bash
conda create -c biobuilds -n biobuilds-2016.11 biobuilds=2016.11
```
This will create a Conda environment called `biobuilds-2016.11`, which you can then use standard Conda commands to manipulate; e.g., `source activate biobuilds-2016.11` and `source deactivate` to enable or disable BioBuilds applications in your $PATH, respectively. Refer to the Conda "[Managing Environments](http://conda.pydata.org/docs/using/envs.html)" documentation for more details.

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

---

**Note**: if you plan to install BioBuilds on a different file system (i.e., mount point) than Miniconda/Anaconda, you may want to prevent `conda` from creating softlinks (symlinks) either by setting the global `allow_softlinks` option to `False` (e.g., by running `conda config --set allow_softlinks false`) or by using the `conda create` `copy` option when installing BioBuilds (i.e., `conda create --copy <other install options>`). This helps avoid symlink-related issues that can prevent applications from correctly finding components like shared libraries or Perl/Python/R modules. Note that either of this options will significantly increase the amount of disk space used by the BioBuilds installation.


# Other notes

While every effort has been made to make BioBuilds as self-contained as possible, various applications still require external libraries and interpreters be installed on the system. If these dependencies are currently not available on your system, you will need either `sudo` access or system administrator help to install them before you can run these applications.

- Linux users on both x86_64 and POWER8 (ppc64le) will need libX11, libXrender, and libXext to run many of the applications that produce graphical or image output (e.g., R or matplotlib). These can be installed by running `sudo apt-get install libx11-6 libxrender1 libxext6` on Debian/Ubuntu-based systems or `sudo yum install libX11 libXrender libXext` on CentOS/RedHat-based systems.
- Linux on POWER8 users will also need libffi and the GCC runtime libraries on their systems. These can be installed by running `sudo apt-get install libffi6 gcc g++ gfortran` on Ubuntu 14.04 or `sudo yum install libffi gcc gcc-g++ gcc-gfortran` on RedHat 7.
- A few applications, including IGV, Trinity, and Picard, require a Java Runtime Environment (JRE) be installed and accessible through your $PATH. The JRE can either be the "official" [Oracle JRE](https://www.java.com/en/download/manual.jsp) or the OpenJDK JRE provided by many distribution vendors. In either case, the JRE must support Java 8 or above.
- The SOAP3-DP and Barracuda applications are GPU-accelerated applications, and therefore, require that the appropriate nVidia hardware and [drivers](http://www.nvidia.com/Download/index.aspx?lang=en-us) (including libcuda.so) be installed on your system.
- Some applications may see performance benefits from specific hardware configurations. In particular, the POWER8 version of the Illumina aligner (iSAAC) has better performance on hardware running in SMT4 or SMT8 mode, with the application's `-j` option set to the appropriate number of hardware threads.

# Applications in BioBuilds 2016.11

The following table lists applications included in the BioBuilds 2016.11 release; note that for brevity, certain support libraries and dependent packages (e.g., individual R packages) are not listed.

| Application   | Version       | Changes since 2016.04   |
|---------------|---------------|-------------------------|
| ALLPATHS-LG   | 52488         | No change (Linux only)  |
| bamkit        | 16.07.26      | New                     |
| BAMtools      | 2.4.0         | No change               |
| Barracuda     | 0.7.107e      | No change (Linux only)  |
| bcftools      | 1.3.1         | Upgrade                 |
| bedops        | 2.4.20        | New                     |
| bedtools      | 2.26.0        | Upgrade                 |
| Bfast         | 0.7.0a        | No change               |
| Bioconductor  | 3.4           | Upgrade                 |
| BioPerl       | 1.6.924       | No change               |
| BioPython     | 1.68          | Upgrade                 |
| Boost         | 1.62.0        | Upgrade                 |
| Bowtie        | 1.1.2         | No change               |
| Bowtie2       | 2.2.9         | Upgrade                 |
| BreakDancer   | 1.4.5         | No change               |
| BWA           | 0.7.15        | Upgrade                 |
| chimerascan   | 0.4.5a        | No change               |
| ClustalW      | 2.1           | No change               |
| conda         | >= 4.2.12     | Upgraded, as needed [1] |
| Cufflinks     | 2.2.1         | No change               |
| cutadapt      | 1.11          | New                     |
| DELLY2        | 0.7.6         | Upgrade                 |
| DIAMOND       | 0.8.24        | New                     |
| EBSEQ (Bioconductor) | 1.14.0        | Upgrade                 |
| EMBOSS        | 6.6.0         | Upgrade                 |
| FASTA         | 36.3.8e       | Upgrade                 |
| FASTQC        | 0.11.5        | No change               |
| FASTX-Toolkit | 0.0.14        | No change               |
| FreeBayes     | 1.0.2         | No change               |
| GenomonFisher | 0.2.0         | Upgrade                 |
| gnuplot       | 5.0.5         | Upgrade                 |
| Graphviz      | 2.38.0        | No change               |
| HMMER         | 3.1b2         | No change               |
| HTSeq         | 0.6.1         | No change               |
| htslib        | 1.3.2         | Upgrade                 |
| IGV           | 2.3.88        | Upgrade                 |
| iSAAC         | 03.16.09.21   | Upgrade (Linux only)    |
| Kraken        | 0.10.5_beta   | New                     |
| LoFreq*       | 2.1.2         | No change               |
| LUMPY-SV      | 0.2.13        | New                     |
| Matplotlib    | 1.5.3         | Upgrade                 |
| Mothur        | 1.38.1        | Upgrade                 |
| MrBayes       | 3.2.6         | No change               |
| MUSCLE        | 3.8.31        | No change               |
| NCBI BLAST+   | 2.5.0         | Upgrade                 |
| NumPy         | 1.11.2        | Upgrade                 |
| Oases         | 0.2.8         | No change               |
| OpenBLAS      | 0.2.19        | Upgrade                 |
| Pandas        | 0.19.1        | Upgrade                 |
| parallel      | 20160922      | New                     |
| Perl          | 5.22.0        | No change               |
| PHYLIP        | 3.696         | No change               |
| Picard        | 2.7.1         | Upgrade                 |
| Pindel        | 0.2.5b8       | No change               |
| PLINK         | 1.07          | No change               |
| PLINK-NG      | 1.90b3.42     | New                     |
| Primer3       | 2.3.7         | New                     |
| Pysam         | 0.8.4         | No change               |
| Python        | 2.7.12        | Upgrade                 |
| R             | 3.3.2         | Upgrade                 |
| R cowplot     | 0.7.0         | New                     |
| R tidyverse   | 1.0.0         | New                     |
| RAxML         | 8.2.9         | New                     |
| RSEM          | 1.3.0         | Upgrade                 |
| Sailfish      | 0.10.0        | Upgrade                 |
| Salmon        | 0.7.2         | New                     |
| SAMBLASTER    | 0.1.23        | New                     |
| Samtools      | 1.3.1         | Upgrade                 |
| scalpel       | 0.5.3         | No change               |
| scikit-bio    | 0.4.2         | New                     |
| SciPy         | 0.18.1        | Upgrade                 |
| Seqtk         | 1.2.94        | New                     |
| SHRiMP        | 2.2.3         | No change               |
| SnpEff        | 4.3c          | Upgrade                 |
| SnpSift       | 4.3c          | Upgrade                 |
| SOAP3-DP      | r177          | No change (Linux only)  |
| SOAPaligner   | 2.20          | No change               |
| SOAPbuilder   | 2.20          | No change               |
| SOAPdenovo2   | 2.4.240       | No change               |
| SPAdes        | 3.9.0         | New                     |
| SplazerS      | 1.3.3         | No change               |
| SQLite        | 3.13.0        | Upgrade                 |
| SRA Tools     | >= 2.8.0      | Upgraded, as needed [2] |
| STAR          | 2.5.2b        | Upgrade                 |
| STAR-fusion   | 0.8.0         | Upgrade                 |
| tabix         | 1.3.2         | Upgrade                 |
| tassel        | 5.2.31        | Upgrade                 |
| T-Coffee      | 11.00.8cbe486 | No change               |
| TMAP          | 3.4.0         | No change               |
| TopHat        | 2.1.1         | No change               |
| Trimmomatic   | 0.36          | New                     |
| Trinity       | 2.2.0         | No change               |
| variant_tools | 2.7.0         | No change               |
| vcftools      | 0.1.14        | New                     |
| Velvet        | 1.2.10        | No change               |


[1] "conda" is the package manager used by BioBuilds and may be upgraded by its provider ([Continuum Analytics](https://www.continuum.io)) as necessary. The version listed here (4.2.12) was the most current when BioBuilds 2016.11 was released, but BioBuilds should work with any newer version of `conda`.

[2] The "SRA Tools" package is marked as "Upgraded, as needed", since updates may be provided through the "biobuilds" conda channel to ensure protocol and/or format compatiblity with the NCBI SRA server. The version listed here (2.8.0) was the most current when BioBuilds 2016.11 was initially released.
