# Hierarchical module naming schemes

<div align="center"><img src="https://boegel.github.io/easybuild-tutorial/img/hmns.png" width="400px"/></div>

## Flat vs hierarchical

## Pros & cons

!!! warning
    no mixing of flat & hierarchical modules!


```shell
module use /easybuild/modules/all
module load EasyBuild
```

```
export EASYBUILD_INSTALLPATH_SOFTWARE=/easybuild/software
export EASYBUILD_MODULE_NAMING_SCHEME=HierarchicalMNS
export EASYBUILD_INSTALLPATH_MODULES=$HOME/hmns/modules
eb HDF5-1.10.6-gompi-2020a.eb --robot --module-only
```

```
$ ls $HOME/hmns/modules/all
Compiler  Core  MPI
```

```
$ module unuse /easybuild/modules/all

Inactive Modules:
  1) EasyBuild
```

```
$ module use $HOME/hmns/modules/all/Core
```

```
$ module avail

--------------------- /home/easybuild/hmns/modules/all/Core ---------------------
   Bison/3.3.2        GCCcore/9.3.0    flex/2.6.4        help2man/1.47.4
   Bison/3.5.3 (D)    M4/1.4.18        gettext/0.20.1    ncurses/6.1
   GCC/9.3.0          binutils/2.34    gompi/2020a       zlib/1.2.11
```

```
$ module load GCC/9.3.0
```

```
$ module avail

-------------- /home/easybuild/hmns/modules/all/Compiler/GCC/9.3.0 --------------
   OpenMPI/4.0.3

------------ /home/easybuild/hmns/modules/all/Compiler/GCCcore/9.3.0 ------------
   Autoconf/2.69         XZ/5.2.5                libtool/2.4.6
   ...
   Szip/2.1.1            libpciaccess/0.16       zlib/1.2.11        (L,D)
   UCX/1.8.0             libreadline/8.0

--------------------- /home/easybuild/hmns/modules/all/Core ---------------------
   Bison/3.3.2        GCCcore/9.3.0 (L)    flex/2.6.4        help2man/1.47.4
   Bison/3.5.3        M4/1.4.18            gettext/0.20.1    ncurses/6.1
   GCC/9.3.0   (L)    binutils/2.34        gompi/2020a       zlib/1.2.11
```

```
$ module avail HDF5
No module(s) or extension(s) found!
Use "module spider" to find all possible modules and extensions.
```

```
$ module spider HDF5
...

    You will need to load all module(s) on any one of the lines below
    before the "HDF5/1.10.6" module is available to load.

      GCC/9.3.0  OpenMPI/4.0.3
```

```
$ module load OpenMPI/4.0.3
```

```
$ module avail

-------- /home/easybuild/hmns/modules/all/MPI/GCC/9.3.0/OpenMPI/4.0.3 -------
   HDF5/1.10.6

------------ /home/easybuild/hmns/modules/all/Compiler/GCC/9.3.0 ------------
   OpenMPI/4.0.3 (L)

...
```

```
$ module load HDF5
$ h5dump --version
h5dump: Version 1.10.6
```


# Exercises

`SciPy-bundle-2020.03-foss-2020a-Python-3.8.2.eb` in HMNS
