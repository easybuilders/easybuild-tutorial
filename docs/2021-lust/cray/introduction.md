# Introduction to the Cray Programming Environment

The Cray Programming Environment (CPE) provides tools designed to maximize developer productivity, application 
scalability, and code performance, including compilers, analyzers, optimized libraries, and debuggers. 

---

## CPE Components

* Cray Compiling Environment (CCE):
  CCE consists of Cray compilers performing code analysis during compilation to generate highly optimized code. 
  Supported languages include Fortran, C and C++, and UPC (Unified Parallel C).

* Cray Scientific and Mathematical Libraries: 
  A set of high performance libraries providing portability for scientific applications, sparse and dense linear
  algebra (BLAS, LAPACK, ScaLAPACK) and fast Fourier transforms (FFTW).

* Cray Message Passing Toolkit
  A collection of software libraries used to perform data transfers between nodes running in parallel applications. 
  It includes the Message Passing Interface (MPI) and OpenSHMEM parallel programming models. 

* Cray Environment Setup and Compiling Support 
  Libraries supporting code compilation and setting up the development environment, including compiler drivers.

* Cray Performance and Analysis Tools:
  Tools to analyze the performance and behavior of programs that are run on Cray systems, and a Performance API (PAPI).

* Cray Debugging Support Tools
  Debugging tools, including `gdb4hpc` and `Valgrind4hpc`

---

## Modules

Modules enable users to modify their environment dynamically by using modulefiles: the `module` command 
provides a user interface to the Environment Modules package. The module command system interprets modulefiles, 
which contain Tool Command Language (Tcl) code, and dynamically modifies shell environment variables such as 
`PATH` and `MANPATH`.
Sites can alternately enable Lmod to handle modules with the Cray Programming Environment on Cray EX Systems. 
Both module systems use the same module names and syntax shown in command-line examples.

> NOTE: Environment Modules and Lmod are mutually exclusive and cannot both run on the same system.

The files `/etc/cray-pe.d/cray-pe-configuration.sh` and `/etc/cray-pe.d/cray-pe-configuration.csh` configuration 
allow sites to customize the default environment and the modules contained in default collections.
To support customer-specific needs, the system administrator can create modulefiles for a product set for the
users. For more information about the Environment Modules software package, see the module(1) and
modulefile(4) manpages.

### Programming Environment meta-modules

Programming Environment modules are organized into meta-modules, where each supports a different compiler suite. 

These modules are `PrgEnv-cray`, `PrgEnv-gnu`, `PrgEnv-aocc`, and `PrgEnv-intel`. 

Meta-modules provide wrappers (`cc`, `CC`, `ftn`) for both CCE and third-party compiler drivers. 

These wrappers call the correct compiler with appropriate options to build and link applications 
with relevant libraries as required by modules loaded, with only dynamic linking supported. 
These wrappers replace direct calls to compiler drivers in Makefiles and build scripts.


### Lmod

In addition to the default Environment Modules system, CPE offers support for Lmod as an alternative module
management system.
Lmod is a Lua-based module system that loads and unloads modulefiles, handles path variables, and manages
library and header files.
The CPE implementation of Lmod is hierarchical, managing module dependencies and ensuring any module a
user has access to is compatible with other loaded modules. 

To ensure optimal assistance from Lmod, it loads related compiler, network, CPU, and MPI modules, 
adding dynamic module paths to the Lmod hierarchy.
Lmod uses "families” of modules to flag circular conflicts, which is most apparent when module details are
displayed through module show and when users attempt to load conflicting modules.
Lmod automatically load a default set of modules. The default set includes one each of compiler, network, CPU,
and MPI modules. Users may choose to load a different module set.

Environment Modules and Lmod modules use the same names, so all command examples work the same
whether using Environment Modules or Lmod.
For more information, please see [The User Guide for Lmod](https://lmod.readthedocs.io/en/latest/010_user.html).

---

## Documentation

[Cray Pubs](https://pubs.cray.com) is the documentation portal of HPE/Cray. 
Documentation on the Cray Programming Environment (PE) can be found under the [PE-Tile](https://pubs.cray.com/category/pe-tile).

The GitHub project [PE-Cray](https://github.com/PE-Cray) provides additional documentation:
- whitepapers are available at https://github.com/PE-Cray/whitepapers

---

*[[next: External Modules]](external_modules.md)*
