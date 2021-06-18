# Using external modules from the Cray PE

EasyBuild supports the use of modules that were not installed via EasyBuild is available. 
We refer to such modules as [external modules](https://docs.easybuild.io/en/latest/Using_external_modules.html).

This feature is used extensively on Cray systems, since several software modules are already provided by the 
Cray PE: [external modules can be used as dependencies](https://docs.easybuild.io/en/latest/Using_external_modules.html#using-external-modules-as-dependencies), by including the module name in the dependencies list, 
along with the `EXTERNAL_MODULE` constant marker.

For example, to specify the module `cray-fftw` as a dependency, you should write the following in your easyconfig file:
```
dependencies = [('cray-fftw', EXTERNAL_MODULE)]
```

For such dependencies, EasyBuild will:

* load the module before initiating the software build and install procedure

* include a `module load` statement in the generated module file (for runtime dependencies)

!!! Note
    The default version of the external module will be loaded unless a specific version is given as dependency

If the specified module is not available, EasyBuild will exit with an error message stating that the dependency 
can not be resolved because the module could not be found, without searching for a matching easyconfig file.

We show in the next sections the main external modules used as dependencies in the Cray PE.

!!! Note
    Component specific manpages are available only when the associated module is loaded.

---

## Compilers

Cray PE supports multiple compilers, Cray and third party compilers as well: AOCC, Cray, Intel, GNU. 

Users can access the compilers loading the modules `PrgEnv-cray` (loaded by default at login), `PrgEnv-gnu`,
`PrgEnv-intel` and `PrgEnv-aocc`.

The corresponding compilers and their respective dependencies will be available, including wrappers and mapping 
(for example, mapping `cc` to `gcc` in `PrgEnv-gnu`).

The commands to invoke compiler wrappers are `ftn` (Fortran), `cc` (C), `CC` (C++).

The online help can be accessed with the `-help` option. E.g.: `cc -help`, `CC -help`.
One of the most frequently used options of the compiler wrappers is `-craype-verbose`:
```
 ftn -help | grep verbose -A 1 
   -craype-verbose              Print the command which is forwarded 
                                to compiler invocation
```
More information is available with the `info` or `man` commands. 
E.g.: both `info cc` or `man cc` will display the man page of the C compiler wrapper.

The compiler wrappers call the correct compiler in the currently loaded programming environment,
with appropriate options to build and link applications with relevant libraries, as required by the modules loaded. 

Therefore compiler wrappers should replace direct calls to compiler drivers in Makefiles and build scripts.

!!! Note
    Only dynamic linking is supported by compiler wrappers on the Cray EX system

---

### Cray Compiling Environment (CCE)

The Cray Compiling Environment is set by the module `PrgEnv-cray`, which is loaded by default at login.

Compiler-specific manpages can be accessed on the system with `man crayftn`, `man craycc` or `man crayCC`.

More details are given in the Cray Fortran Reference Manual and the Cray Compiling Environment Release
available on [Cray Pubs](https://pubs.cray.com). 
The [Clang Compiler User’s Manual](https://clang.llvm.org/docs/UsersManual.html) 
is another source of information for the Cray C and C++ Clang compilers.

The Cray Compiling Environment (CCE) provides Fortran, C and C++ compilers that perform substantial analysis
during compilation and automatically generate highly optimized code. 

For more information about compiler pragmas and directives, see `man intro_directives` on the system.

---

## Third-Party Compilers


### AOCC

The module `PrgEnv-aocc` loads the default AMD Optimizing C/C++ Compiler 
and sets the corresponding programming environment.

Compiler-specific documentation is available in the [AOCC User Guide](https://developer.amd.com/amd-aocc/#userguide).

Cray provides a bundled package of support libraries to install into the PE environment to enable AOCC, 
and Cray PE utilities such as debuggers and performance tools work with AOCC.

### GNU

The module `PrgEnv-gnu` loads the default GNU Compiler 
and sets the corresponding programming environment: 
the Cray PE bundles and enables the open-source GNU Compiler Collection (GCC). 

Compiler-specific manpages can be accessed on the system with `man gfortran`, `man gcc` or `man g++`.

More details are provided by the [GCC online documentation](https://gcc.gnu.org/onlinedocs).


### Intel

The module `PrgEnv-intel` loads the default Intel Compiler
and sets the corresponding programming environment: 
the Cray PE enables the Intel® oneAPI compiler and tools. 

The documentation is avaible in the [Intel® oneAPI Programming Guide](https://software.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup.html)

Cray provides a bundled package of support libraries to install into the Cray PE to enable the Intel compiler, allowing
utilities such as debuggers and performance tools to work with it. 

---

## Cray Scientific and Math Library

* Modules: `cray-libsci`, `cray-fftw`

* Manpages: `intro_libsci`, `intro_fftw3`

The Cray Scientific and Math Libraries (CSML, also known as LibSci) are a collection of numerical routines
optimized for best performance on Cray systems. 

These libraries satisfy dependencies for many commonly used applications on Cray systems for a wide variety of domains. 

When the module for a CSML package (such as `cray-libsci` or `cray-fftw`) is loaded, 
all relevant headers and libraries for these packages are added to the compile 
and link lines of the `cc`, `ftn`, and `CC` compiler wrappers.

--- 

## Scientific Libraries provided by CSML

The CSML collection contains the following Scientific Libraries:

* BLAS (Basic Linear Algebra Subroutines)
* BLACS (Basic Linear Algebra Communication Subprograms)
* CBLAS (Collection of wrappers providing a C interface to the Fortran BLAS library)
* IRT (Iterative Refinement Toolkit)
* LAPACK (Linear Algebra Routines)
* LAPACKE (C interfaces to LAPACK Routines)
* ScaLAPACK (Scalable LAPACK)
* `libsci_acc` (library of Cray-optimized BLAS, LAPACK, and ScaLAPACK routines)
* NetCDF (Network Common Data Format)
* FFTW3 (the Fastest Fourier Transforms in the West, release 3)

---

## Cray MPICH

* Modules: `cray-mpich`
* Manpages: `intro_mpi`
* Website: [http://www.mpi-forum.org](http://www.mpi-forum.org)

MPI is a widely used parallel programming model that establishes a practical, portable, efficient, 
and flexible standard for passing messages between ranks in parallel processes. 

Cray MPI is derived from Argonne National Laboratory MPICH and implements the MPI-3.1 standard 
as documented by the MPI Forum in MPI: A Message Passing Interface Standard, Version 3.1.

Support for MPI varies depending on system hardware. To see which functions and environment variables the
system supports, please have a look at the corresponding man pages with `man intro_mpi` on the system.

--- 

## DSMML

* Modules: `cray-dsmml`
* Manpages: `intro_dsmml`
* Website: [https://pe-cray.github.io/cray-dsmml](https://pe-cray.github.io/cray-dsmml)

Distributed Symmetric Memory Management Library (DSMML) is a HPE Cray proprietary memory management library.

DSMML is a standalone memory management library for maintaining distributed shared symmetric memory
heaps for top-level PGAS languages and libraries like Coarray Fortran, UPC, and OpenSHMEM. 

DSMML allows user libraries to create multiple symmetric heaps and share information with other libraries. 

Through DSMML, interoperability can be extracted between PGAS programming models.

Further details are available in the man page on the system with `man intro_dsmml`.

---

## EasyBuild Metadata

[Metadata](https://docs.easybuild.io/en/latest/Using_external_modules.html#metadata-for-external-modules)
 can be supplied to EasyBuild for external modules: using the `--external-modules-metadata` 
configuration option, the location of one or more metadata files can be specified.

The files are expected to be in INI format, with a section per module name 
and key-value assignments specific to that module.

The external modules metadata file can be also defined with the corresponding environment variable:
```
echo $EASYBUILD_EXTERNAL_MODULES_METADATA 
/apps/common/UES/jenkins/production/easybuild/cpe_external_modules_metadata-21.04.cfg
```

The following keys are 
[supported by EasyBuild](https://docs.easybuild.io/en/latest/Using_external_modules.html#supported-metadata-values):

* name: software name(s) provided by the module
* version: software version(s) provided by the module
* prefix: installation prefix of the software provided by the module

For instance, the external module version loaded by the dependency `cray-fftw` can be specified as follows:
```ini
[cray-fftw]
name = FFTW
prefix = FFTW_DIR/..
version = 3.3.8.10
```

The environment variable `$EBROOTFFTW` will also be defined according to the `prefix` specified in the metadata file.

---

## CPE meta-module

The Cray PE on the EX system provides the meta-module `cpe`: the purpose of the meta-module is
similar to the scope of the `cdt` and `cdt-cuda` meta-modules available on the XC systems.

```
$ module show cpe
--------------------------------------------------------------------------------------------------------------------------------
   /opt/cray/pe/lmod/modulefiles/core/cpe/21.04.lua:
--------------------------------------------------------------------------------------------------------------------------------
setenv("LMOD_MODULERCFILE","/opt/cray/pe/cpe/21.04/modulerc.lua")
unload("PrgEnv-cray")
load("PrgEnv-cray/8.0.0")
unload("craype")
load("craype/2.7.6")
unload("cray-libsci")
load("cray-libsci/21.04.1.1")
unload("cce")
load("cce/11.0.4")
unload("cray-mpich")
load("cray-mpich/8.1.4")
unload("perftools-base")
load("perftools-base/21.02.0")
unload("cray-dsmml")
load("cray-dsmml/0.1.4")
```

The meta-module loads the correct default versions of the modules with the selected Cray PE version, 
as defined by the corresponding `LMOD_MODULERCFILE` referenced in the module.

A site can create custom versions of the meta-module, in order to to override the module defaults.

*[[next: Custom Toolchains]](custom_toolchains.md)*
