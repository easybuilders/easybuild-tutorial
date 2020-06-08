# Introduction

## What is EasyBuild?

[EasyBuild](http://easybuilders.github.io/easybuild/) is a **software build and installation framework**
that manages (scientific) software in an efficient way, without compromises on performance. Easybuild is especially tailored towards [**High Performance Computing (HPC)**](https://en.wikipedia.org/wiki/Supercomputer)
 environments.


### *Elevator pitch*

<a href="http://geek-and-poke.com/geekandpoke/2010/5/14/how-to-become-invaluable.html"><img src="https://boegel.github.io/easybuild-tutorial/img/geek-and-poke-invaluable.png" style="float:right" width="350px"/></a>

EasyBuild intends to relieve HPC support teams from manually managing
software installations while at the same time **providing a consistent and well performing
scientific software stack** to end users of HPC systems.

It serves as a **uniform interface for installing scientific software**
and saves valuable time (and frustration) by the automation of tedious, boring and repetitive tasks. 

In addition, EasyBuild can **empower scientific researchers to self-manage their software stack**,
and it can serve as a tool that can be leveraged for **building optimized container images**.

The project has grown out to be a **platform for collaboration** with HPC sites worldwide.


### *Key features*

EasyBuild is capable of **fully autonomously installing (scientific) software**,
including making sure that all necessary dependencies are installed,
and automatically generating environment module files.

***No*** **admin privileges are required**: it is sufficient to have write permissions
to the preferred software installation prefix.

It is [**highly configurable**](https://easybuild.readthedocs.io/en/latest/Configuration.html) via configuration files, environment variables, and command line options.
The functionality can be [**dynamically extended**](https://easybuild.readthedocs.io/en/latest/Including_additional_Python_modules.html) via plugins,
and hooks are available for further site-specific [**customizations**](https://easybuild.readthedocs.io/en/latest/Hooks.html) if required.

The installation procedure executed by EasyBuild is thoroughly [**logged**](https://easybuild.readthedocs.io/en/latest/Logfiles.html) and fully transparent via [dry run](https://easybuild.readthedocs.io/en/latest/Extended_dry_run.html) and [tracing](https://easybuild.readthedocs.io/en/latest/Tracing_progress.html).

EasyBuild supports using a **custom module naming scheme**, allows for
*hierarchical* module naming schemes, and **integrates with various other tools** ranging from  resource managers [(Slurm](https://slurm.schedmd.com) and [GC3Pie](https://github.com/gc3pie/gc3pie)),
container tools ([Singularity](https://github.com/hpcng/singularity) and [Docker](https://www.docker.com)),
packaging tools ([FPM](https://fpm.readthedocs.io)), and so on.

The project is **actively developed** by a worldwide community, with stable versions being
released every 6-8 weeks since 2012. **Comprehensive testing** practices are applied throughout the
development cycle, with extensive suites of unit and integration tests being run in a CI environment,
consistent testing of incoming contributions, and thorough regression testing before every release.


### *What EasyBuild is* ***not***

EasyBuild is ***not*** **YABT (Yet Another Build Tool)**: it does not replace established build
tools like CMake or ``make``, it wraps around them.
If the installation procedure of a software package involves running some unholy trinity of tools while whispering
the correct magic incantations, EasyBuild automates this process for you.

It is ***not*** **a replacement for traditional Linux package manangers** like ``yum``, ``dnf`` or ``apt``.
EasyBuild relies on certain tools and libraries provided by the operating system. This includes glibc, OpenSSL, Infiniband, GPU drivers, and so on. It is required that these tools are installed and managed by other means. This is typically done via the package management tool that comes with your Linux distribution.

Finally, EasyBuild is ***not a magic solution to all your (software installation) problems**.
You may, and probably will still occasionally, run into compiler errors unless somebody has already taken care of the problem for you.


### *Implementation*

<img src="https://boegel.github.io/easybuild-tutorial/img/Python-logo.png" style="border-right: 20px solid white;border-top: 5px solid white; float:left" width="80px"/>


EasyBuild is **implemented in [Python](https://www.python.org/)**, and fully supports both Python 2.7 and 3.5+.

Releases are published via [PyPI](https://pypi.org/project/easybuild/),
under the [GPLv2 open source license](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

Development is done through the [**``easybuilders`` organisation on GitHub**](https://github.com/easybuilders/),
where each of the EasyBuild components is hosted in a separate repository.

--- 


## Terminology

Over the years, we have come up with some terminology specific to EasyBuild
to refer to particular components, which we use alongside established terminology relevant to the context
of building and installing software.

It is important to be familiar with these terms.


### *Framework*

The EasyBuild *framework* consists of a set of Python modules organised in packages (``easybuild.framework``,
``easybuild.tools``, etc.) that collectively form **the heart of EasyBuild**.

It implements the **common functionality that you need when building software from source**,
providing functions for unpacking source files, applying patch files, collecting the output produced
by shell commands that are being run and checking their exit code, generating environment module files, etc.

The EasyBuild framework does not implement any specific installation procedure, it only provides
the necessary functionality to facilitate this (see <a href="#easyblocks">easyblocks</a>).


### *Easyblocks*

An *easyblock* is **a Python module that implements a specific software installation procedure**.
It can be viewed as a plugin to the EasyBuild framework.

Easyblocks can be either *generic* or *software-specific*.

A **generic easyblock** implements an installation procedure that can be used for
multiple different software packages. Commonly used examples include the ``ConfigureMake`` easyblock
which implements the ubiquitous ``configure``-``make``-``make install`` procedure, and the
``PythonPackage`` easyblock that can be used to install a Python package.

A **software-specific** easyblock implements an installation procedure that is specific to a particular
software packages. Infamous examples include the easyblocks we have for ``GCC``, ``OpenFOAM``, ``TensorFlow``, ...

The installation procedure performed by an easyblock can be controlled by defining
**easyconfig parameters** (see <a href="#easyconfig-files">easyconfig files</a>).


### *Easyconfig files*

*Easyconfig files* (or *easyconfigs* for short), are **simple text files written in Python syntax
that specify what EasyBuild should install**.
They define the different **easyconfig parameters** that collectively form a complete specification
for a particular software installation.

**Some easyconfig parameters are mandatory**. The following parameters *must* be defined in each easyconfig file:

* ``name`` and ``version``, which specify the name and version of the software to install (surprise!);
* ``homepage`` and ``description``, which provide key metadata for the software;
* ``toolchain``, which specifies the compiler toolchain to use to install the software (see
  ``toolchains`` tab);

Other easyconfig parameters are optional: they **can be used to provide required information,
or to control specific aspects of the installation procedure performed by the easyblock**.

Some commonly used optional easyconfig parameters include:

* ``easyblock``, which specifies which (generic) easyblock should be used;
* ``sources`` and ``source_urls``, which specify the list of source files and where to download them;
* ``dependencies`` and ``builddependencies``, which specify (drum roll...) the list of (build) dependencies;
* ``configopts``, ``buildopts``, and ``installopts``, which specify options for the configuration/build/install commands, respectively;

If these parameters are not provided, the corresponding default value will be used.

### *Extensions*

*Extensions* is the collective term we use for **additional software packages that can be installed
on top of another software package**. Examples are *Python packages*, *R libraries* and *Perl modules*.
As you can tell, the software terminology here is a mess, so we had to come of up with a unifying term...

<div align="center"><a href="https://xkcd.com/927/"><img src="https://imgs.xkcd.com/comics/standards.png" width="350px"></a></div>

Extensions can be installed in different ways:

* stand-alone, as a separate installation on top of one or more other installations;
* as a part of a bundle of extensions that collectively form a separate installation;
* or as an *extension* to a specific installation to yield a "batteries included"
  type of installation (for examples by adding a bunch of Python packages from PyPI into
  a Python installation);

### *Dependencies*

A *dependency* is a common term in the context of software. It refers to **a software
package that is either strictly required by other software, or that can be leveraged to
enhance other software** (for example to support specific features).

There are three main types of dependencies for computer software:

* a **build dependency** is only required when building/installing a software package;
  once the software package is installed, it is no longer needed to *use* that software;
* a **runtime dependency** (often referred to simply as *dependency*) is a software package that is
  required to *use* (or *run*) another software package;
* a **link-time dependency** is somewhere in between a build and runtime dependency: 
  it is only needed when *linking* a software package; it can become either a build or runtime
  dependency, depending on exactly how the software is installed;

The distinction between link-time and build/runtime dependencies is irrelevant for this tutorial.

### *Toolchains*

A *compiler toolchain* (or just *toolchain* for short) is a **set of [compilers](https://en.wikipedia.org/wiki/Compiler)**,
which are used to build software from source, together with a set of **additional libraries** that provide further core functionality.

We refer to the different parts of a toolchain as **toolchain components**.

The *compiler component* typically consists of [C](https://en.wikipedia.org/wiki/C_(programming_language)),
[C++](https://en.wikipedia.org/wiki/C%2B%2B), and [Fortran](https://en.wikipedia.org/wiki/Fortran)
compilers in the context of HPC, but additional compilers (for example,
a [CUDA](https://developer.nvidia.com/cuda-zone) compiler for
[GPGPU](https://en.wikipedia.org/wiki/General-purpose_computing_on_graphics_processing_units) software)
can also be included.

Additional toolchain components are usually special-purpose libraries:

* an MPI library to support distributed computations (for example, [Open MPI](https://www.open-mpi.org/));
* libraries providing efficient linear algebra routines ([BLAS](http://performance.netlib.org/blas/),
  [LAPACK](http://performance.netlib.org/lapack/));
* a library supporting computing Fast Fourier Transformations (for example, [FFTW](http://fftw.org/));

A toolchain that includes all of these libraries is referred to as a **full toolchain**, while
a **subtoolchain** is a toolchain that is missing one or more of these libraries.
A **compiler-only toolchain** only consists of compilers (no additional libraries).

### *Modules*

*Module* is a massively overloaded term in (scientific) software and IT in general
(kernel modules, Python modules, and so on).
In the context of EasyBuild, the term 'module' usually refers to an **environment module (file)**.

Environment modules is a well established concept on HPC systems: it is a way to
specify changes that should be made to one or more
[environment variables](https://en.wikipedia.org/wiki/Environment_variable) in a
[shell](https://en.wikipedia.org/wiki/Shell_(computing))-agnostic way. A module file
is usually written in either [Tcl](https://en.wikipedia.org/wiki/Tcl) or
[Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)) syntax,
and specifies which environment variables should be updated, and how (append,
prepend, (re)define, undefine, etc.) upon loading the environment module.
Unloading the environment module will restore the shell environment to its previous state.

Environment module files are processed via a **modules tool**, of which there
are several conceptually similar yet slighty different implementations.
The Tcl-based [Environment Modules](https://sourceforge.net/projects/modules/) implementation, and
[Lmod](https://lmod.readthedocs.io), a more recent Lua-based implementation (which also supports module
files written in Tcl syntax), are the most commonly used ones.

EasyBuild heavily relies on environment modules, and hence **having a modules tool installed
is a strict requirement in order to use EasyBuild**.
Both Lmod and the Tcl-based Environment Modules tools are supported
by EasyBuild, as well as module files in both Tcl and Lua syntax.

**Module files are automatically generated for each software installation** by EasyBuild,
and *loading* a module results in changes being made to the environment of the current shell
session such that the corresponding software installation can be used.

### *Bringing it all together*

The EasyBuild **framework** leverages **easyblocks** to automatically build and install
(scientific) software, potentially including additional **extensions**, using a particular compiler **toolchain**,
as specified in **easyconfig files**.

EasyBuild ensures that the specified **dependencies** are met upon a successful install,
and automatically generates a set of **(environment) modules** that facilitate access to the installed software.

--- 


## Focus points

EasyBuild was created specifically for **installing scientific software on HPC systems**,
which is reflected in some of the design choices that were made.


### *Performance*

EasyBuild strongly prefers to **build software from source code**, whenever possible.

This is important to ensure that the binaries that are installed can maximally exploit
the capabilities of the system architecture on which the software will be run.

For that same reason, EasyBuild **optimizes software for the processor architecture of the build host**
by default, via compiler options like ``-march=native`` (GCC), ``-xHost`` (Intel compilers), etc.
This behaviour [may be changed via the ``--optarch`` configuration setting](https://easybuild.readthedocs.io/en/latest/Controlling_compiler_optimization_flags.html).


### *Reproducibility*

In addition to performance, **reproducibility of installations** is a core aspect of EasyBuild.

Most software installations performed with EasyBuild use a **particular <a href="#toolchains">toolchain</a>**,
with which we aim to take control over the build environment and avoid relying on tools and libraries
provided by the operating system. For similar reasons, we try to **provide all required dependencies through EasyBuild** as well,
with a few notable exceptions, like ``OpenSSL`` for security reasons, and Infiniband and GPU drivers which
are too closely intertwined with the operating system.

For both toolchains and dependencies, **fixed software versions** are specified in the
<a href="#easyconfig-files">easyconfig files</a>. That way, easyconfig files can easily be shared with others:
if they worked for you it is very likely that they will work for others too, because the vast majority of the
software stack is controlled by EasyBuild.


### *Community effort*

In a number of different ways, we try to encourage EasyBuild users to **collaborate** and help each other out.

We actively recommend people to report problems and bugs, to submit ideas for additional features and improvements,
and to [**contribute back**](https://easybuild.readthedocs.io/en/latest/Contributing.html) when possible, be it
by opening pull requests to the <a href="#framework">EasyBuild framework</a>, <a href="#easyblocks">easyblocks</a>,
<a href="#easyconfig-files">easyconfigs</a> repositories, or to the <a href="https://easybuild.readthedocs.io">EasyBuild documentation</a>.

Through the ``foss`` and ``intel`` [**common toolchains**](https://easybuild.readthedocs.io/en/latest/Common-toolchains.html),
we try to focus the efforts of the EasyBuild community a bit to specific toolchains,
which increases the usefulness of the easyconfig files we collect in the [central repository](https://github.com/easybuilders/easybuild-easyconfigs).

Last but not least, EasyBuild provides various [**GitHub integration features**](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html)
that greatly facilitate the contribution process: opening, updating, and testing pull requests,
reviewing incoming contributions, and much more can all be done directly from the EasyBuild
command line. This not only saves time, effort, brain cycles, and mouse clicks for contributors, but 
it also makes the review process for *maintainers* significantly easier. All together this leads to improved stability and consistency.

--- 


## The EasyBuild community

EasyBuild was originally created by the [HPC team at Ghent University (Belgium)](https://www.ugent.be/hpc/en) in 2009,
and was developed in-house before it was publicly released in 2012.

Since then it has grown out to a [**community project**](https://github.com/easybuilders),
which is used and developed by various HPC centres and consortia worldwide, including (but not limited to):

* [Flemish Supercomputer Centre (VSC), Belgium](https://www.vscentrum.be/)
* [Consortium des Équipements de Calcul Intensif (CÉCI), Belgium](http://www.ceci-hpc.be/)
* [Jülich Supercomputing Centre (JSC), Germany](https://www.fz-juelich.de/ias/jsc/EN/Home/home_node.html)
* [Swiss National Supercomputing Centre (CSCS)](https://www.cscs.ch/)
* [Birmingham Environment for Academic Research (BEAR), UK](https://intranet.birmingham.ac.uk/bear/)
* [SURFsara, Netherlands](https://www.surf.nl/en/expertises/compute-services)
* [Swedish National Infrastructure for Computing (SNIC)](https://www.snic.se/)
* [Compute Canada](https://www.computecanada.ca/)
* [Fred Hutchinson Cancer Research Center, US](https://www.fredhutch.org)
* [Texas A&M University (TAMU) High Performance Research Computing (HPRC), US](https://hprc.tamu.edu/)
* [National University of Singapore (NUS)](https://nusit.nus.edu.sg/hpc/)
* [University of Melbourne, Australia](https://dashboard.hpc.unimelb.edu.au/)
* [HPCNow!](https://hpcnow.com/)

Today, an [experienced team of HPC experts](https://easybuild.readthedocs.io/en/latest/Maintainers.html) actively maintains the project,
by implementing additional features and bug fixes, and processing incoming contributions.

The EasyBuild documentation is available at [**https://easybuild.readthedocs.io**](https://easybuild.readthedocs.io).
You can interact with the EasyBuild community via the [**Slack channel**](https://easybuild.slack.com/)
(request an invitation [here](https://easybuild-slack.herokuapp.com/)),
or by subscribing to the [**mailing list**](https://lists.ugent.be/wws/subscribe/easybuild).
