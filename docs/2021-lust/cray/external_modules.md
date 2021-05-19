# Cray External Modules

EasyBuild supports the use of modules that were not installed via EasyBuild is available. 
We refer to such modules as [external modules](https://docs.easybuild.io/en/latest/Using_external_modules.html).

This feature is used extensively on Cray systems, since several software modules are already provided by the 
CPE: [external modules can be used as dependencies](https://docs.easybuild.io/en/latest/Using_external_modules.html#using-external-modules-as-dependencies), by including the module name in the dependencies list, 
along with the `EXTERNAL_MODULE` constant marker.

For example, to specify the module `cray-fftw` as a dependency:
```
dependencies = [('cray-fftw', EXTERNAL_MODULE)]
```

For such dependencies, EasyBuild will:
* load the module before initiating the software build and install procedure
* include a `module load` statement in the generated module file (for non-build dependencies)

If the specified module is not available, EasyBuild will exit with an error message stating that the dependency 
can not be resolved because the module could not be found, without searching for a matching easyconfig file.

We show the main external modules used as dependencies in the Cray Programming Environment.

> NOTE: Library-specific manpages are available only when the associated module is loaded.

---

## Compilers

The CPE supports multiple compilers, Cray and third party compilers as well: Cray, AOCC, Intel, GNU. 
Users can access the compilers loading the modules `PrgEnv-cray` (loaded by default at login), `PrgEnv-gnu`,
`PrgEnv-intel` and `PrgEnv-aocc`.
The corresponding compilers and their respective dependencies will be available, including wrappers and mapping 
(for example, mapping `cc` to `gcc` in `PrgEnv-gnu`).

Command to invoke compiler wrappers: `ftn` (Fortran), `cc` (C), `CC` (C++)
Online help: `cc -help`, `CC -help`

Compiler wrappers call the correct compiler with appropriate options to build and link applications with relevant libraries as
required by modules loaded. These wrappers replace direct calls to compiler drivers in Makefiles and build scripts.

> Only dynamic linking is supported by compiler wrappers

---

### Cray Compiling Environment (CCE)

Module: `PrgEnv-cray`
Compiler-specific manpages: crayftn(1), craycc(1), crayCC(1)
Documentation: Cray Fortran Reference Manual, Cray Compiling Environment Release
Overview: [Clang Users Manual](https://clang.llvm.org/docs/UsersManual.html)

The Cray Compiling Environment (CCE) provides Fortran, C and C++ compilers that perform substantial analysis
during compilation and automatically generate highly optimized code. 
For more detailed information about the Cray Fortran, C, and C++ compiler command-line arguments, see the
crayftn(1), craycc(1), and crayCC(1) manpages, respectively.

One of the most useful compiler features is the ability to generate annotated loopmark listings showing what
optimization were performed and their locations. Together with compiler messages, these listings can help zero-in
on areas in the code that are compiling without error but not fully optimized.

For more information about compiler pragmas and directives, see the intro_directives(1) manpages.

---

## Third-Party Compilers


### AOCC

Module: `PrgEnv-aocc`
Documentation: [AOCC 2.1 User Guide](https://developer.amd.com/wp-content/resources/AOCC-2.1-User-Guide.pdf)

The CPE enables the AMD Optimizing C/C++ Compiler 2.1 (AOCC). 

Cray provides a bundled package of support libraries to install into the PE environment to enable AOCC, 
and Cray PE utilities such as debuggers and performance tools work with AOCC.

### GNU

Module: `PrgEnv-gnu`
Compiler-specific manpages: gcc(1), gfortran(1), g++(1)
Documentation: [GCC online documentation](https://gcc.gnu.org/onlinedocs)

The CPE bundles and enables the open-source GNU Compiler Collection (GCC). 

### Intel

Module: `PrgEnv-intel`
Documentation: [Intel® oneAPI Programming Guide](https://software.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup.html)

The CPE enables the Intel® oneAPI compiler and tools. 

Cray provides a bundled package of support libraries to install into the CPE to enable the Intel compiler, allowing
utilities such as debuggers and performance tools to work with the Intel compiler. 

---

## Cray Scientific and Math Library

Modules: `cray-libsci`, `cray-fftw`
Manpages: `intro_libsci`, `intro_fftw3`

The Cray Scientific and Math Libraries (CSML, also known as LibSci) are a collection of numerical routines
optimized for best performance on Cray systems. These libraries satisfy dependencies for many commonly used
applications on Cray systems for a wide variety of domains. When the module for a CSML package (such as
cray-libsci or cray-fftw) is loaded, all relevant headers and libraries for these packages are added to the
compile and link lines of the cc, ftn, and CC Cray PE drivers.

### Scientific Libraries:

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

Modules: `cray-mpich`
Manpages: `intro_mpi`
Websites: http://www.mpi-forum.org

MPI is a widely used parallel programming model that establishes a practical, portable, efficient, and flexible
standard for passing messages between ranks in parallel processes. Cray MPI is derived from Argonne National
Laboratory MPICH and implements the MPI-3.1 standard as documented by the MPI Forum in MPI: A Message
Passing Interface Standard, Version 3.1.
Support for MPI varies depending on system hardware. To see which functions and environment variables the
system supports, check the `intro_mpi` manpages.

--- 

## DSMML

Modules: `cray-dsmml`
Manpages: `intro_dsmml`
Websites: https://pe-cray.github.io/cray-dsmml

Distributed Symmetric Memory Management Library (DSMML) is a proprietary memory management library.
DSMML is a standalone memory management library for maintaining distributed shared symmetric memory
heaps for top-level PGAS languages and libraries like Coarray Fortran, UPC, and OpenSHMEM. DSMML allows
user libraries to create multiple symmetric heaps and share information with other libraries. Through DSMML,
interoperability can be extracted between PGAS programming models.
Refer to the `intro_dsmml` manpage for more details.

---

## EasyBuild Metadata

Metadata can be supplied to EasyBuild for external modules.

Using the `--external-modules-metadata` configuration option, the location of one or more metadata files can be specified.
The files are expected to be in INI format, with a section per module name and key-value assignments specific to that module.

CSCS systems define the external modules metadata file with environment varialbles:
```
echo $EASYBUILD_EXTERNAL_MODULES_METADATA 
/apps/common/UES/jenkins/production/easybuild/alps_external_modules_metadata-21.05.cfg
```
The files are also available on the [CSCS GitHub production repository](https://github.com/eth-cscs/production). 

For instance, the external module version loaded by the dependency `cray-fftw` is specified in [alps-external_modules_metadata-21.05.cfg](https://github.com/eth-cscs/production/blob/master/easybuild/alps-external_modules_metadata-21.05.cfg)
```
[cray-fftw]
name = FFTW
prefix = FFTW_DIR/..
version = 3.3.8.10
```
The environment variable `EBROOTFFTW` will also be defined according to the `prefix` specified in the metadata file. 

*[[next: Custom Toolchains]](custom_toolchains.md)*
