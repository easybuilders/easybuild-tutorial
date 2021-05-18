# Cray External Modules


For each external module of the Cray Programming Environment, man pages are provided on the system.

> NOTE: Library-specific manpages are available only when the associated module is loaded.

---

## Compilers

...

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

## Third party libraries

...

---

## EasyBuild Metadata

...

*[[next: Custom Toolchains]](custom_toolchains.md)*
