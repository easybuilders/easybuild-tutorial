# Introduction to the Cray Programming Environment

The Cray Programming Environment (PE) provides tools designed to maximize developer productivity, application 
scalability, and code performance, including compilers, analyzers, optimized libraries, and debuggers. 

---

## Cray PE Components

* __Cray Compiling Environment (CCE)__:

  CCE consists of Cray compilers performing code analysis during compilation to generate highly optimized code. 
  Supported languages include Fortran, C and C++, and UPC (Unified Parallel C).

* __Cray Scientific and Mathematical Libraries__: 

  A set of high performance libraries providing portability for scientific applications, sparse and dense linear
  algebra (BLAS, LAPACK, ScaLAPACK) and fast Fourier transforms (FFTW).

* __Cray Message Passing Toolkit__:

  A collection of software libraries used to perform data transfers between nodes running in parallel applications. 
  It includes the Message Passing Interface (MPI) and OpenSHMEM parallel programming models. 

* __Cray Environment Setup and Compiling Support__:
  
  Libraries supporting code compilation and setting up the development environment, including compiler drivers.

* __Cray Performance and Analysis Tools__:

  Tools to analyze the performance and behavior of programs that are run on Cray systems, and a Performance API (PAPI).

* __Cray Debugging Support Tools__:

  Debugging tools, including `gdb4hpc` and `Valgrind4hpc`.

---

## Modules

Modules enable users to modify their environment dynamically by using modulefiles: 
the `module` command provides a user interface to the [Environment Modules](https://modules.readthedocs.io) package. 

The module command interprets modulefiles, which contain Tool Command Language (Tcl) code, 
and dynamically modifies shell environment variables such as `PATH` and `MANPATH`.

Cray sites can alternately enable [Lmod](https://lmod.readthedocs.io) to handle modules with the 
Cray Programming Environment on Cray EX Systems. 

Both module systems use the same module names and syntax shown in command-line examples.

!!! Note
    Environment Modules and Lmod are mutually exclusive and cannot both run on the same system.

The configuration files `/etc/cray-pe.d/cray-pe-configuration.sh` and `/etc/cray-pe.d/cray-pe-configuration.csh` 
allow sites to customize the default environment. 

To support customer-specific needs, the system administrator 
can create modulefiles for a product set for the users: 

* for more information about the Environment Modules software package see the help screen `module -h`.

---

## Programming Environment meta-modules

Programming Environment modules are organized into meta-modules, where each supports a different compiler suite. 

These modules are `PrgEnv-aocc`, `PrgEnv-cray`, `PrgEnv-gnu` and `PrgEnv-intel`. 

Meta-modules provide wrappers (`cc`, `CC`, `ftn`) for both Cray and third-party compiler drivers.

The main purposes of using the Cray wrappers are the following:

1. call the correct compiler with appropriate options to build and link applications 

1. link relevant libraries as required by modules loaded, with only dynamic linking supported 

1. replace direct calls to compiler drivers in Makefiles and build scripts

---

### Lmod

In addition to the default Environment Modules system, Cray PE offers support 
for [Lmod](https://lmod.readthedocs.io) as an alternative module management system.

Lmod is a Lua-based module system that loads and unloads modulefiles, handles path variables, and manages
library and header files.

The Cray PE implementation of Lmod is hierarchical, managing module dependencies and ensuring any module a
user has access to is compatible with other loaded modules. 

Lmod loads related compiler, network, CPU, and MPI modules adding dynamic module paths to the Lmod hierarchy:

* "families" of modules are used to flag circular conflicts, for instance: 
 - when module details are displayed through `module show`
 - when users attempt to load conflicting modules

* a default set of modules is loaded automatically: the default set includes compiler, network, CPU and MPI modules

* Users may choose to load a different module set, 
defining [user collections](https://lmod.readthedocs.io/en/latest/010_user.html#user-collections-label)

Environment Modules and Lmod modules use the same names in the Cray Programming Environment, 
therefore all command examples work the same whether using Environment Modules or Lmod.

For more information, please refer to the [User Guide for Lmod](https://lmod.readthedocs.io/en/latest/010_user.html).

---

## Documentation

[Cray Pubs](https://pubs.cray.com) is the documentation portal of HPE/Cray 
and the main source of the information provided in this tutorial. 

Documentation on the Cray Programming Environment (PE) can be found under 
the [PE-Tile](https://pubs.cray.com/category/pe-tile). 
The page provides links to the following content:

* PE Release Announcements

* PE Installation & Configuration

* Cray Compiling Environment (CCE)

* PE User Procedures (including Cray Programming Environment User Guides)

The GitHub project [PE-Cray](https://github.com/PE-Cray) provides additional documentation:

* Whitepapers are available at [https://github.com/PE-Cray/whitepapers](https://github.com/PE-Cray/whitepapers)

* Documentation for [cray-openshmemx](https://github.com/PE-Cray/cray-openshmemx)

* Information on [cray-dsmml](https://github.com/PE-Cray/cray-dsmml)

---

*[[next: External Modules]](external_modules.md)*
