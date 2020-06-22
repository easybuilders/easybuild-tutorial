# Comparison with other tools

<div align="center"><a href="https://xkcd.com/927/"><img src="https://imgs.xkcd.com/comics/standards.png" width="60%"></a></div>

---

<p><img src="../img/spack_logo.png" alt="Spack logo" width="25%"/></p>

The project that most compares with EasyBuild is <a href="https://spack.io/">Spack</a>, a flexible package manager for HPC systems.

It was created by [Todd Gamblin](https://github.com/tgamblin) at [Lawrence Livermore National Lab
(LLNL)](https://www.llnl.gov) in California, USA.

In several ways it looks similar to EasyBuild:

* implemented in Python, compatible with Python 2.6 and 3.5+
* open source software, development on GitHub
* similar high-level structure (core + packages)
* supports installing (scientific) software without admin privileges
* strong focus on HPC and performance
* highly configurable
* well documented (see [https://spack.readthedocs.io/](https://spack.readthedocs.io))
* generates environment modules files
* worldwide community
* broad spectrum of supported software (1000s)

In other ways, EasyBuild and Spack are quite different. Spack is released
under a more permissive open source license (MIT/Apache 2.0 dual license), and 
whereas EasyBuild supports Linux and Cray PE, Spack adds macOS out-of-the-box.

The Spack command line interface is quite different from EasyBuild: it
supports subcommands (like "`spack install`"), and provides a flexible interface
for specifying an abstract specification of what to install. Here is an example:

```shell
spack install mpileaks@3.3 ^mpich@3.2 %gcc@4.9.3
```

This tells Spack to install `mpileaks` version 3.3 on top of MPICH version 3.2, using GCC 4.9.3 as compiler.

This abstract specification is then passed to a *concretization algorithm*
which fills in the blanks: it will pick versions of other required dependencies,
determine which compiler flags to use, and so on. This information is fed to the
Spack package (which is the equivalent of an easyblock in EasyBuild) to perform
the actual installation.

There are many other differences between EasyBuild and Spack as well, too many for this document to cover in detail. See the [*"Installing software for scientists on a multi-user HPC system"*](https://archive.fosdem.org/2018/schedule/event/installing_software_for_scientists/) recorded talk at FOSDEM'18 and the Spack documentation for more information.


---

<p><img src="../img/nix_logo.png" alt="Nix logo" width="15%"/>
<img src="../img/guix_logo.png" alt="Guix logo" width="15%"/></p>

[Nix](https://nixos.org/) and [GNU Guix](https://gnu.org/s/guix/) are both
*purely functional package managers*, which strongly focus on the reproducibility
of software installations.

In Nix packages are expressed as *Nix expressions* (a custom DSL), and software
installations are usually done in the Nix store, a dedicated installation directory, each in a specific subdirectory
that includes a unique identifier for that installation. For example:

```
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```

Guix is very similar to Nix, but is a separate project entirely.
There is a dedicated [Guix HPC](https://hpc.guix.info/) community that focuses on the use of Guix in an HPC context.
Packages in Guix are implemented in Guile Scheme, and many advanced features
like transactional upgrades and rollbacks are supported.

To the best of our knowledge, neither of these tools have seen wide adoption
in the HPC community to date.

---

<p><img src="../img/conda_logo.png" alt="conda logo" width="20%"/></p>

[Conda](https://docs.conda.io/en/latest/) is a package manager that
runs on Windows, macOS and Linux, and is very popular in the scientific
community.

It focuses on quick installation of software and ease of use, and lets users create
a *conda environment* in which they can install one or more packages.
These packages are usually *pre-built generic binaries* however,
which significantly impacts the performance of the installations.

Despite wide adoption in the scientific community `conda` is not a good fit
for HPC systems for a number of reasons, including poor support for multi-user
environments, a lack of focus on performance, heavily relying on the home
directory (which usually is limited in size on HPC systems), and more.
See [this link](https://docs.computecanada.ca/wiki/Anaconda/en) for a more detailed discussion.

In addition, software installed via `conda` usually does not mix well with
software installed through environment modules.
