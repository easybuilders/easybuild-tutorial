## 1.1 What is EasyBuild?

[EasyBuild](http://easybuilders.github.io/easybuild/) is a **software build and installation framework**
that allows you to manage (scientific) software on High Performance Computing (HPC) systems in an efficient way,
without compromising on performance.

It is implemented in [Python](https://www.python.org/), supports both Python 2.7 and 3.5+,
and is released under the [GPLv2 open source license](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

EasyBuild is also:

* a uniform interface that wraps around software installation procedures;
* a huge time-saver, by automating tedious/boring/repetitive tasks;
* an expert system for software installation on HPC systems;
* a mechanism to provide a consistent software stack to the users of HPC systems;
* a tool to empower scientific researchers to self-manage their software stack;
* a platform for collaboration with HPC sites worldwide;
* a tool that can be leveraged for building optimised container images;

It is ***not***:

* YABT (Yet Another Build Tool): it does not replace build tools like CMake or ``make``, it wraps around them;

* a replacement for package managers (``yum``, /``dnf``, ``apt``, ...): it leverages some tools & libraries provided by the OS (glibc, OpenSSL, Infiniband & GPU drivers, ...);

* a magic solution to all your (software installation) problems: you may (and will) still run into compiler errors (unless somebody has already taken care of it);


**Key features** of EasyBuild include:

* fully autonomously installation of (scientific) software;
* automatic dependency resolution;
* automatic generation of environment module files;
* no admin privileges required;
* thorough logging of the executed installation procedure;
* highly configurable, via configuration files, environment variables, and command line options;
* dynamically extendable (via plugins) and customizable (via hooks);
* support for using a custom module naming scheme (incl. hierarchical);
* transparency w.r.t. automated installation procedure;
* comprehensively tested: lots of unit tests, frequent regression testing;
* actively developed, frequent stable releases (every 6-8 weeks);
* integration with other tools like resource managers (Slurm), container tools (Singularity, Docker), etc.;

## 1.2 Who's behind it?

It was originally created by the [HPC team at Ghent University (Belgium)](https://www.ugent.be/hpc/en) in 2009,
and was developed in-house before it was publicly released in 2012.

Since then it has grown out to a **community project**, which is used and developed by various HPC centres
& consortia worldwide, including (but not limited to):

* [Flemish Supercomputer Centre (VSC), Belgium](https://www.vscentrum.be/)
* [Consortium des Équipements de Calcul Intensif (CÉCI), Belgium](http://www.ceci-hpc.be/)
* [Jülich Supercomputing Centre (JSC), Germany](https://www.fz-juelich.de/ias/jsc/EN/Home/home_node.html)
* [Swiss National Supercomputing Centre (CSCS)](https://www.cscs.ch/)
* [Birmingham Environment for Academic Research (BEAR), UK](https://intranet.birmingham.ac.uk/bear/)
* [SURFsara, Netherlands](https://www.surf.nl/en/expertises/compute-services)
* [Swedish National Infrastructure for Computing (SNIC)](https://www.snic.se/)
* [Compute Canada](https://www.computecanada.ca/)
* [Texas A&M University (TAMU) High Performance Research Computing (HPRC), US](https://hprc.tamu.edu/)
* [National University of Singapore (NUS)](https://nusit.nus.edu.sg/hpc/)
* [University of Melbourne, Australia](https://dashboard.hpc.unimelb.edu.au/)

EasyBuild is actively maintained by an [experienced team of HPC experts](https://easybuild.readthedocs.io/en/latest/Maintainers.html),
who implement additional features and bug fixes, and also review and process incoming contributions.

Development is done through the [**``easybuilders`` organisation on GitHub**](https://github.com/easybuilders/),
where each of the EasyBuild components is hosted in a separate repository.

The EasyBuild documentation is available at [**https://easybuild.readthedocs.io**](https://easybuild.readthedocs.io).
You can interact with the EasyBuild community via the [**Slack channel**](https://easybuild.slack.com/)
(request an invitation [here](https://easybuild-slack.herokuapp.com/)),
or subscribe to the [**mailing list**](https://lists.ugent.be/wws/subscribe/easybuild).


## 1.3 Terminology

Over the years, we have come up with some terminology specific to EasyBuild
to refer to particular components, which we use alongside established terminology relevant to the context
of building and installing software.

It is important that you're familiar with these terms.

*(click on the tabs below to see the description of each term)*

=== "framework"

    The EasyBuild *framework* consists of a set of Python modules organised in packages (``easybuild.framework``,
    ``easybuild.tools``, etc.) that collectively form **the heart of EasyBuild**.

    It implements the **common functionality that you need when building software from source**,
    providing functions for unpacking source files, applying patch files, collecting the output produced
    by shell commands that are being run and checking their exit code, generating environment module files, etc.

    The EasyBuild framework does not implement any specific installation procedure, it only provides
    the necessary functionality to facilitate this (see ``easyblocks`` tab).

=== "easyblocks"

    An *easyblock* is **a Python module that implements a specific software installation procedure**.
    It can be viewed as a plugin to the EasyBuild framework.

    Easyblocks can be either *generic* or *software-specific*.

    A **generic easyblock** implements an installation procedure that can be used for
    multiple different software packages. Commonly used examples include the ``ConfigureMake`` easyblock
    which implements the ubiquitous ``configure``-``make``-``make install`` procedure, and the
    ``PythonPackage`` easyblock that can be used to install a Python package.

    A **software-specific** easyblock implements an installation procedure that is specific to a particular
    software packages. Infamous examples include the easyblocks we have for ``GCC``, ``OpenFOAM``, ``TensorFlow``, ...

    The installation procedure performed by an easyblock can be controlled by defining so-called
    **easyconfig parameters** (see `easyconfigs` tab).

=== "easyconfigs"

    *Easyconfig files* (or *easyconfigs* for short), are **simple text files (written in Python syntax)
    that specify what EasyBuild should install**.
    They define the different **easyconfig parameters** that collectively form a complete specification
    for a particular software installation.

    **Some easyconfig parameters are mandatory**, these *must* be defined in each easyconfig file:

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
    * ``configopts``, ``buildopts``, and ``installopts``, which speficy options for the configuration/build/install commands, resp.;

=== "extensions"

    *Extensions* is the collective term we use for **additional software packages that can be installed
    on top of another software package**. Examples are *Python packages*, *R libraries* and *Perl modules*
    (can you tell why we had to come up with a different term?).

    Extensions can be installed in different ways:

    * stand-alone, as a separate installation on top of one or more other installations;
    * as a part of a bundle of extensions that collectively form a separate installation;
    * or as, well, an *extension* to a specific installation to yield a "batteries included"
      type of installation (for examples by adding a bunch of Python packages from PyPI into
      a Python installation);

=== "dependencies"

    A *dependency* is a common term in the context of software, which we probably don't need to define at length,
    but here it goes anyway: it refers to **a software package that is either strictly required by other software, 
    or that can be leveraged to enhance other software** (to support specific features for example).

    There are multiple types of dependencies:

    * a **build dependency** is only required when building/installing a software package;
      once the software package is installed, it is no longer needed to *use* that software;
    * a **runtime dependency** (or just *dependency* for short) is a software package that is
      required to *use* (or *run*) another software package;
    * a **link-time dependency** is somewhere in between a build and runtime dependency: 
      it is only needed when *linking* a software package; it can become either a build or runtime
      dependency, depending (hah!) on how the software is installed exactly;

    The distinction between link-time and build/runtime dependencies is mostly irrelevant for this tutorial though.

=== "toolchains"

    A *compiler toolchain* (or just *toolchain* for short) is a **set of [compilers](https://en.wikipedia.org/wiki/Compiler)**,
    which are used to build software from source, and **additional libraries** which provide specific functionality.

    We refer to the different parts of a toolchain as **toolchain components**.

    The *compiler component* typically consists of [C](https://en.wikipedia.org/wiki/C_(programming_language)),
    [C++](https://en.wikipedia.org/wiki/C%2B%2B) and [Fortran](https://en.wikipedia.org/wiki/Fortran)
    compilers in the context of HPC, but additional compilers (for example,
    a [CUDA](https://developer.nvidia.com/cuda-zone) compiler for
    [GPGPU](https://en.wikipedia.org/wiki/General-purpose_computing_on_graphics_processing_units) software)
    can also be included.

    Additional toolchain components typically are special-purpose libraries:

    * an MPI library to support distributed computations (for example, [Open MPI](https://www.open-mpi.org/));
    * libraries providing efficient linear algebra routines ([BLAS](http://performance.netlib.org/blas/),
      [LAPACK](http://performance.netlib.org/lapack/));
    * a library supporting computing Fast Fourier Tranforms (for example, [FFTW](http://fftw.org/));

    A toolchain that includes all of these libraries is referred to as a **full toolchain**, while
    a **subtoolchain** is a toolchain that is missing one or more of these libraries.
    A **compiler-only toolchain** only consists of compilers (no additional libraries).

=== "modules"

    *Module* is a massively overloaded term in (scientific) software and IT in general
    (kernel modules, Python modules, etc.).
    In the context of EasyBuild, the term 'module' usually refers to an **environment module (file)**.

    Environment modules is a well established concept on HPC systems: it is a way to
    specify changes that should be made to one or more
    [environment variables](https://en.wikipedia.org/wiki/Environment_variable) in a
    [shell](https://en.wikipedia.org/wiki/Shell_(computing))-agnostic way. A module file
    is usually written in either [Tcl](https://en.wikipedia.org/wiki/Tcl) or
    [Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)) syntax,
    and specifies for which environment variables the value should be updated, and how (append,
    prepend, (re)define, undefine, etc.).

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

---

To bring it all together: the EasyBuild *framework* leverages *easyblocks* to automatically build and install
(scientific) software, potentially including additional *extensions*, using a particular compiler *toolchain*,
as specified in *easyconfig files*. EasyBuild ensures that the specified *dependencies* are installed,
and automatically generates a set of *(environment) modules* that facilitate access to the installed software.

## 1.4 Design choices (WIP)

- building from source
- target host architecture by default
- toolchains, try to avoid host compiler/tools/libraries, fixed versions, reproducibility
