# EasyBuild at CSCS

EasyBuild has been used at CSCS since 2015 on multiple systems, using both Cray and standard toolchains.

CSCS staff has integrated EasyBuild within the automated pipelines used to maintain supported applications and 
libraries for CSCS users. The pipelines are stored on GitHub and are currently launched on a Jenkins server.

CSCS Production Repository on GitHub: [https://github.com/eth-cscs/production](https://github.com/eth-cscs/production)

Jenkins Pipelines: [https://github.com/eth-cscs/production/tree/master/jenkins](https://github.com/eth-cscs/production/tree/master/jenkins)

How to use EasyBuild at CSCS: [https://user.cscs.ch/computing/compilation/easybuild](https://user.cscs.ch/computing/compilation/easybuild)

--- 

## Custom EasyBuild module

The EasyBuild framework is available at CSCS through the custom module `EasyBuild-custom`. 

This module defines the location of the EasyBuild configuration files, recipes and installation directories.
```
module load EasyBuild-custom
```
The default installation folder is instead the following:
```
$HOME/easybuild/<system-name>
```

Where `<system-name>` is the lowercase name of the system, e.g.: `eiger`.

The [custom EasyBuild modulefile](https://github.com/eth-cscs/production/tree/master/easybuild/module/EasyBuild-custom) is available both in Tcl and Lua syntax on the [CSCS production repository](https://github.com/eth-cscs/production):

* a system using Lmod for module management will load the Lua modulefile, which is ignored by systems using 
Environment modules instead.

The modulefile defines the location of the EasyBuild configuration files, the recipes and the installation directories. 

Once you have loaded the EasyBuild modulefile, you can check the EasyBuild version loaded and the default configuration 
executing the EasyBuild command `eb`  with the options `--version`  or `--show-config` as usual.

---

## How to use EasyBuild at CSCS

Example on the Cray EX supercomputing system Eiger:
```
ml show EasyBuild-custom

---------------------------------------------------------------------------------------------------------------------------------
   /apps/eiger/UES/modulefiles/EasyBuild-custom/cscs.lua:
---------------------------------------------------------------------------------------------------------------------------------
help([[
Description
===========
Production EasyBuild @ CSCS

More information
================
 - Homepage: https://github.com/eth-cscs/production/wiki
]])
whatis("Description: Production EasyBuild @ CSCS  ")
whatis("Homepage: https://github.com/eth-cscs/production/wiki")
conflict("EasyBuild-custom")
setenv("EBROOTEASYBUILDMINCUSTOM","/apps/common/UES/jenkins/easybuild/software/EasyBuild-custom/cscs")
setenv("EBVERSIONEASYBUILDMINCUSTOM","cscs")
setenv("EBDEVELEASYBUILDMINCUSTOM","/apps/common/UES/jenkins/easybuild/software/EasyBuild-custom/cscs/easybuild/EasyBuild-custom-cscs-easybuild-devel")
setenv("XDG_CONFIG_DIRS","/apps/common/UES/jenkins/production/easybuild")
setenv("EASYBUILD_ROBOT_PATHS","/apps/common/UES/jenkins/production/easybuild/easyconfigs/:")
setenv("EASYBUILD_INCLUDE_EASYBLOCKS","/apps/common/UES/jenkins/production/easybuild/easyblocks/*.py")
setenv("EASYBUILD_INCLUDE_MODULE_NAMING_SCHEMES","/apps/common/UES/jenkins/production/easybuild/tools/module_naming_scheme/*.py")
setenv("EASYBUILD_INCLUDE_TOOLCHAINS","/apps/common/UES/jenkins/production/easybuild/toolchains/*.py,/apps/common/UES/jenkins/production/easybuild/toolchains/compiler/*.py")
setenv("EASYBUILD_BUILDPATH","/run/user/21827/build")
setenv("EASYBUILD_TMPDIR","/run/user/21827/tmp")
setenv("EASYBUILD_SOURCEPATH","/apps/common/UES/easybuild/sources")
setenv("EASYBUILD_EXTERNAL_MODULES_METADATA","/apps/common/UES/jenkins/production/easybuild/cpe_external_modules_metadata-21.04.cfg")
setenv("EASYBUILD_MODULE_NAMING_SCHEME","HierarchicalMNS")
setenv("EASYBUILD_MODULE_SYNTAX","Lua")
setenv("EASYBUILD_MODULES_TOOL","Lmod")
setenv("EASYBUILD_OPTARCH","x86-rome")
setenv("EASYBUILD_RECURSIVE_MODULE_UNLOAD","0")
setenv("EASYBUILD_PREFIX","/users/lucamar/easybuild/eiger")
```

---

## CSCS EasyBuild configuration

```
eb --version
This is EasyBuild 4.4.0 (framework: 4.4.0, easyblocks: 4.4.0) on host uan01.

eb --show-config
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
allow-loaded-modules          (F) = ddt, EasyBuild-custom, EasyBuild, xalt
buildpath                     (E) = /run/user/21827/build
containerpath                 (E) = /users/lucamar/easybuild/eiger/containers
external-modules-metadata     (E) = /apps/common/UES/jenkins/production/easybuild/cpe_external_modules_metadata-21.04.cfg
hide-deps                     (F) = absl, ANTLR, APR, APR-util, arpack-ng, Autoconf, Automake, Autotools, backports.weakref, Bazel, binutils, Bison, bokeh, byacc, bzip2, cairo, cloudpickle, configurable-http-proxy, Coreutils, Cube, CUDA, cuDNN, cURL, DB, Doxygen, Eigen, expat, flex, FLTK, fontconfig, freetype, funcsigs, gc, GCCcore, gettext, GL2PS, GLib, glmnet, GLPK, GMP, gnuplot, go, gperf, GPGME, GraphicsMagick, groff, GTS, guile, help2man, hwloc, inputproto, IPython, JasPer, jemalloc, kbproto, Libassuan, libcerf, libdrm, libevent, libfabric, libffi, libgd, libGLU, libgpuarray, libiberty, libjpeg-turbo, libjpeg-turbo, libpciaccess, Libpgp-error, libpng, libpthread-stubs, libQGLViewer, libreadline, libsodium, libspatialindex, LibTIFF, libtool, libunistring, libunwind, libutempter, libX11, libXau, libxcb, libXdmcp, libXext, libxml2, libXrender, libxshmfence, libyaml, LLVM, LOKI, Loki, LVM2, M4, make, makeinfo, Mako, Mesa, minieigen, mock, mxml, NASM, NASM, ncurses, nettle, networkx, nodejs, nose-parameterized, numactl, OPARI2, OpenMPI, OpenPGM, parameterized, PCRE, PDT, Perl, PIL, Pillow, pixman, pkg-config, ploticus, PMIx, popt, prereq, protobuf, protobuf-core, PyGTS, PyQt, Python-bare, Python-Xlib, PyYAML, PyZMQ, Qhull, qrupdate, Qt, renderproto, runc, scikit-image, scikit-learn, SCons, SCOTCH, Serf, SIP, SQLite, SWIG, Szip, Tcl, Tk, UCX, UDUNITS, UnZip, util-linux, Werkzeug, wheel, X11, xcb-proto, xextproto, xorg-macros, xproto, xtrans, XZ, ZeroMQ, zlib, zstd
hide-toolchains               (F) = CrayCCE, CrayGNU, CrayIntel, CrayPGI, GCCcore, gmvapich2, gmvolf, foss, fosscuda, gompi
include-easyblocks            (E) = /apps/common/UES/jenkins/production/easybuild/easyblocks/*.py
include-module-naming-schemes (E) = /apps/common/UES/jenkins/production/easybuild/tools/module_naming_scheme/*.py
include-toolchains            (E) = /apps/common/UES/jenkins/production/easybuild/toolchains/*.py, /apps/common/UES/jenkins/production/easybuild/toolchains/compiler/*.py
installpath                   (E) = /users/lucamar/easybuild/eiger
module-naming-scheme          (E) = HierarchicalMNS
optarch                       (E) = x86-rome
packagepath                   (E) = /users/lucamar/easybuild/eiger/packages
prefix                        (E) = /users/lucamar/easybuild/eiger
repositorypath                (E) = /users/lucamar/easybuild/eiger/ebfiles_repo
robot-paths                   (E) = /apps/common/UES/jenkins/production/easybuild/easyconfigs/, /apps/common/UES/easybuild/software/EasyBuild/4.4.0/easybuild/easyconfigs
sourcepath                    (E) = /apps/common/UES/easybuild/sources
tmpdir                        (E) = /run/user/21827/tmp
```

---

## Configuration options

As reported in the output of the command `eb --show-config`, the configuration items labeled with `(E)` 
are defined by an environment variable of the form `EASYBUILD_<item>`, where `item` is in uppercase letters. 

Therefore the buildpath is defined by the variable `EASYBUILD_BUILDPATH`, whereas the prefix that defines 
the installpath of the modules created by EasyBuild is defined by `EASYBUILD_PREFIX`. 

You can change these configuration items editing the corresponding environment variable. 

Please note that in general the prefix might be different with respect to the installpath: special care is required
in particular when users would like to build additional modules in their local folders on top of EasyBuild modules 
already provided by the HPC centre staff.

---

## Choosing your custom folders

You can override the default installation folder by exporting the environment variables listed below, 
before loading the EasyBuild modulefile:
```
export EASYBUILD_PREFIX=/your/preferred/installation/folder
export EB_CUSTOM_REPOSITORY=/your/local/repository/easybuild
module load EasyBuild-custom
```

The first environment variable is generally set before loading the EasyBuild modulefiles. 

The second one is instead specific to the CSCS EasyBuild-custom modulefile and corresponds 
to the EasyBuild variable `XDG_CONFIG_DIRS`: therefore, the custom modulefile expects to find 
the subfolders of the easybuild directory under the CSCS GitHub production repository. 

The following environment variables depend on `EB_CUSTOM_REPOSITORY`:
```
setenv XDG_CONFIG_DIRS                          $::env(EB_CUSTOM_REPOSITORY)
setenv EASYBUILD_ROBOT_PATHS                    $::env(EB_CUSTOM_REPOSITORY)/easyconfigs/:
setenv EASYBUILD_INCLUDE_EASYBLOCKS             $::env(EB_CUSTOM_REPOSITORY)/easyblocks/*.py
setenv EASYBUILD_INCLUDE_MODULE_NAMING_SCHEMES  $::env(EB_CUSTOM_REPOSITORY)/tools/module_naming_scheme/*.py
setenv EASYBUILD_INCLUDE_TOOLCHAINS             $::env(EB_CUSTOM_REPOSITORY)/toolchains/*.py,$::env(EB_CUSTOM_REPOSITORY)/toolchains/compiler/*.py
```
Users will find the CSCS EasyBuild configuration file under the folder `easybuild.d` of the `EB_CUSTOM_REPOSITORY` 
and the CSCS custom recipes under the `easyconfigs` folder, listed as usual in alphabetical order.

---

## Customizing your build recipes

If you wish to extend or customize the CSCS EasyBuild recipes, you can clone the [CSCS production project](https://github.com/eth-cscs/production.git) from GitHub and have your private repository:
```
git clone https://github.com/eth-cscs/production.git
```

The command will download the project files under a newly created folder production. 
If you wish to use it as your custom repository, you need to export the corresponding EasyBuild environment variable:
```
export EB_CUSTOM_REPOSITORY=/<your_local_path>/production/easybuild
module load EasyBuild-custom
```

You will find the CSCS EasyBuild build recipes files under `/<your_local_path>/production/easybuild/easyconfigs`, 
with application folders listed in alphabetical order.

---

## EasyBuild configuration file

The custom configuration of EasyBuild at CSCS is completed by the [site wide configuration file](https://github.com/eth-cscs/production/blob/master/easybuild/easybuild.d/system_wide.cfg) available in the folder `easybuild.d` under `XDG_CONFIG_DIRS`, referenced in the modulefile `EasyBuild-custom`.

The file defines the following:

* the list of hidden dependencies

* the list of hidden toolchains

* the list of allowed loaded modules
 
The current content of the file is reported below:
```
[override]
# Comma separated list of dependencies that you want automatically hidden, (e.g. --hide-deps=zlib,ncurses) (type comma-separated list)
hide-deps=absl,ANTLR,APR,APR-util,arpack-ng,Autoconf,Automake,Autotools,backports.weakref,Bazel,binutils,Bison,bokeh,byacc,bzip2,cairo,cloudpickle,configurable-http-proxy,Coreutils,Cube,CUDA,cuDNN,cURL,DB,Doxygen,Eigen,expat,flex,FLTK,fontconfig,freetype,funcsigs,gc,GCCcore,gettext,GL2PS,GLib,glmnet,GLPK,GMP,gnuplot,go,gperf,GPGME,GraphicsMagick,groff,GTS,guile,help2man,hwloc,inputproto,IPython,JasPer,jemalloc,kbproto,Libassuan,libcerf,libdrm,libevent,libfabric,libffi,libgd,libGLU,libgpuarray,libiberty,libjpeg-turbo,libjpeg-turbo,libpciaccess,Libpgp-error,libpng,libpthread-stubs,libQGLViewer,libreadline,libsodium,libspatialindex,LibTIFF,libtool,libunistring,libunwind,libutempter,libX11,libXau,libxcb,libXdmcp,libXext,libxml2,libXrender,libxshmfence,libyaml,LLVM,LOKI,Loki,LVM2,M4,make,makeinfo,Mako,Mesa,minieigen,mock,mxml,NASM,NASM,ncurses,nettle,networkx,nodejs,nose-parameterized,numactl,OPARI2,OpenMPI,OpenPGM,parameterized,PCRE,PDT,Perl,PIL,Pillow,pixman,pkg-config,ploticus,PMIx,popt,prereq,protobuf,protobuf-core,PyGTS,PyQt,Python-bare,Python-Xlib,PyYAML,PyZMQ,Qhull,qrupdate,Qt,renderproto,runc,scikit-image,scikit-learn,SCons,SCOTCH,Serf,SIP,SQLite,SWIG,Szip,Tcl,Tk,UCX,UDUNITS,UnZip,util-linux,Werkzeug,wheel,X11,xcb-proto,xextproto,xorg-macros,xproto,xtrans,XZ,ZeroMQ,zlib,zstd
module-syntax=Tcl
hide-toolchains=CrayCCE,CrayGNU,CrayIntel,CrayPGI,GCCcore,gmvapich2,gmvolf,foss,fosscuda,gompi
allow-loaded-modules=ddt,EasyBuild-custom,EasyBuild,xalt
```

---

## EasyBuild on Piz Daint

On Piz Daint, which is a heterogeneous system, you need to select which architecture 
should be targeted when building software. 

You can target the Intel Haswell architecture accessing the gpu software stack using the command:
```
module load daint-gpu EasyBuild-custom
```

Alternatively, you can target the Intel Broadwell architecture and the mc (multicore) software stack:
```
module load daint-mc EasyBuild-custom
```

On Piz Daint, EasyBuild software and modules will be installed by default under the following folder:
```
$HOME/easybuild/<system-name>/<architecture>
```

Here `<architecture>` will be either `haswell` or `broadwell`.

---

## Building your Program

After you load the EasyBuild environment as explained in the section above, 
you will have the command eb available to build your code using EasyBuild. 

If you want to build the code using a given configuration `<filename>.eb` and resolving dependencies, 
you will use the flag `-r` as in the example below:
```
eb <filename>.eb -r
```

The build command just needs the configuration file name with the extension `.eb` and not the full path, 
provided that the configuration file is in your search path: the command `eb --show-config` will print 
the variable robot-paths that holds the search path. 

More options are available, please have a look at the short help message typing `eb -h`. 

For instance, you can check if any EasyBuild configuration file already exists for a given program name, using the search flag -S:
```
eb -S <program_name>
```

Please note that on Cray systems you can use the configuration files that rely of a Cray toolchain, 
which you will find in the configuration filename (`eb -S <name> | grep Cray`). 

You will be able to load the modules created by EasyBuild in the folder defined by the `EASYBUILD_PREFIX` 
variable using the following commands:
```
module use $EASYBUILD_PREFIX/modules/all
module load <modulename>/version
```

The command module use will prepend the selected folder to your MODULEPATH environment variable, 
therefore you will see the new modules with module avail. 

Please note that by default `EASYBUILD_PREFIX` is set to a folder inside your `$HOME`, 
however the `$HOME` folder is by default not readable by other users. 

Therefore if you want to make your builds available to your group, then you need to allow read-only access 
to other members of your group using the command `chmod g+rx $HOME`.
