# Introduction to EasyBuild

<p align="center"><img src="../../img/easybuild_logo_alpha.png" alt="EasyBuild logo" width="300px"/></p>

## What is EasyBuild?

**[EasyBuild](https://easybuild.io)** is a **software build and installation framework**
that manages (scientific) software in an efficient way, without compromising on performance.
Easybuild is especially tailored towards [**High Performance Computing (HPC)**](https://en.wikipedia.org/wiki/Supercomputer) systems,
and provides a **command-line interface** to facilitate the installation and management of a scientific software stack.

### History

EasyBuild as a project was conceived in 2008 by the [HPC team at Ghent University (Belgium)](https://www.ugent.be/hpc/en).
The first public release of EasyBuild was made available early 2012.
[EasyBuild v1.0.0](https://pypi.org/project/easybuild/#history) was released in November 2012, during the Supercomputing 2021 conference.

Following the public release and the projects introduction into the HPC community,
other sites started to use EasyBuild and actively contribute to the project.
Over the years EasyBuild has grown into a **community project**,
which is used and developed by hundreds of HPC centres and consortia worldwide.

---

<a href="https://geek-and-poke.com/geekandpoke/2010/5/14/how-to-become-invaluable.html">
<img src="../../img/geek-and-poke-invaluable.png" style="float:right" width="45%"/>
</a>

## EasyBuild in a nutshell

EasyBuild intends to relieve HPC support teams from manually managing
software installations while at the same time **providing a consistent and well performing
scientific software stack** to end users of HPC systems.

It serves as a **uniform interface for installing scientific software**
and saves valuable time (and frustration) by the automation of tedious, boring and repetitive tasks.

In addition, EasyBuild can **empower scientific researchers to self-manage their software stack**,
and it can serve as a tool that can be leveraged for **building optimized container images**.

The project has grown to become a **platform for collaboration** among HPC sites worldwide,
and has become an "expert system" for installing scientific software on HPC systems.

---

## Key features

EasyBuild is capable of **fully autonomously installing (scientific) software**,
including making sure that all necessary dependencies are installed,
and automatically generating environment module files.

***No*** **admin privileges are required**: it is sufficient to have write permissions
to the preferred software installation prefix.

EasyBuild is [**highly configurable**](https://docs.easybuild.io/en/latest/Configuration.html) via configuration files,
environment variables, and command line options. The functionality can be
[**dynamically extended**](https://docs.easybuild.io/en/latest/Including_additional_Python_modules.html) via plugins,
and [**hooks**](https://docs.easybuild.io/en/latest/Hooks.html) are available for further site-specific customizations.

The installation procedure executed by EasyBuild is thoroughly
[**logged**](https://docs.easybuild.io/en/latest/Logfiles.html), and is fully transparent via support for
[**dry runs**](https://docs.easybuild.io/en/latest/Extended_dry_run.html) and
[**tracing**](https://docs.easybuild.io/en/latest/Tracing_progress.html) the software installation procedure
as it is performed.

EasyBuild supports using a **custom module naming scheme**, allows for
*hierarchical* module naming schemes, and **integrates with various other tools** ranging from  resource managers ([Slurm](https://slurm.schedmd.com) and [GC3Pie](https://github.com/gc3pie/gc3pie)),
container tools ([Singularity](https://github.com/apptainer/singularity) and [Docker](https://www.docker.com)),
packaging tools ([FPM](https://fpm.readthedocs.io)), and so on.

---

### Focus points

EasyBuild was created specifically for **installing scientific software on HPC systems**,
which is reflected in some of the design choices that were made.


#### Performance

EasyBuild strongly prefers to **build software from source code**, whenever possible.

This is important to ensure that the binaries that are installed can maximally exploit
the capabilities of the system architecture on which the software will be run.

For that same reason, EasyBuild **optimizes software for the processor architecture of the build host**
by default, via compiler options like ``-march=native`` (GCC), ``-xHost`` (Intel compilers), etc.
This behaviour [can be changed via the ``--optarch`` configuration setting](https://docs.easybuild.io/en/latest/Controlling_compiler_optimization_flags.html).


#### Reproducibility

In addition to performance, **reproducibility of installations** is a core aspect of EasyBuild.

Most software installations performed with EasyBuild use a **particular compiler <a href="#toolchains">toolchain</a>**,
with which we aim to be in control over the build environment and avoid relying on tools and libraries
provided by the operating system. For similar reasons, we try to **provide all required dependencies through EasyBuild** as well,
with a few notable exceptions, like ``OpenSSL`` for security reasons, and Infiniband and GPU drivers which
are too closely intertwined with the operating system.

For both toolchains and dependencies, **fixed software versions** are specified in the
<a href="#easyconfig-files">easyconfig files</a>. That way, easyconfig files can easily be shared with others:
if they worked for you it is very likely that they will work for others too, because the vast majority of the
software stack is controlled by EasyBuild.


#### Community effort

In a number of different ways, we try to encourage EasyBuild users to **collaborate** and help each other out.

We actively recommend people to report problems and bugs, to submit ideas for additional features and improvements,
and to [**contribute back**](https://docs.easybuild.io/en/latest/Contributing.html) when possible, be it
by opening pull requests to the [GitHub repositories](https://github.com/easybuilders) or the [documentation](https://docs.easybuild.io).

Through the ``foss`` and ``intel`` [**common toolchains**](https://easybuild.readthedocs.io/en/latest/Common-toolchains.html),
we try to focus the efforts of the EasyBuild community a bit to specific toolchains,
which increases the usefulness of the easyconfig files we collect in the [central repository](https://github.com/easybuilders/easybuild-easyconfigs).

Last but not least, EasyBuild provides various [**GitHub integration features**](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html)
that greatly facilitate the contribution process: opening, updating, and testing pull requests,
reviewing incoming contributions, and much more can all be done directly from the EasyBuild
command line. This not only saves time, effort, brain cycles, and mouse clicks for contributors,
but it also makes the review process for *maintainers* significantly easier.
All together this leads to improved stability and consistency.

---

### What EasyBuild is *not*

EasyBuild is ***not*** **YABT (Yet Another Build Tool)**: it does *not* replace established build
tools like CMake or ``make``, it wraps around them.
If the installation procedure of a software package involves running some unholy trinity of tools while whispering
the correct magic incantations, EasyBuild automates this process for you.

It is ***not*** **a replacement for traditional Linux package managers** like ``yum``, ``dnf`` or ``apt``.
EasyBuild relies on certain tools and libraries provided by the operating system. This includes glibc, OpenSSL,
drivers for Infiniband and GPUs, and so on. It is required that these tools are installed and managed by other means.
This is typically done via the package management tool that comes with your Linux distribution.

Finally, EasyBuild is ***not*** **a magic solution to all your (software installation) problems**.
You may, and probably still will occasionally, run into compiler errors unless somebody has already taken care of the problem for you.


---

[*next: Terminology*](terminology.md) - [*(back to overview page)*](index.md)
