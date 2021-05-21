# EasyBuild at CSCS

EasyBuild has been used at CSCS since 2015 on multiple systems, using both Cray and standard toolchains.

*(to be completed)*

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
Where `<system-name>` is the login name of the system, e.g.: `daint`.

The custom EasyBuild modulefile is written in Tcl syntax and it is available in the CSCS production repositoy. 

It defines the location of the EasyBuild configuration files, the recipes and the installation directories. 

Once you have loaded the EasyBuild modulefile, you can check the EasyBuild version loaded and the default configuration 
executing the EasyBuild command `eb`  with the options `--version`  or `--show-config` as usual.

---

## CSCS EasyBuild configuration

```
eb --show-config
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
allow-loaded-modules      (F) = ddt, EasyBuild-custom, EasyBuild, xalt
buildpath                 (E) = /run/user/21827/easybuild/build
containerpath             (E) = /users/lucamar/easybuild/pilatus/containers
external-modules-metadata (E) = /apps/common/UES/jenkins/production/easybuild/alps-external\_modules\_metadata-21.04.cfg
hide-deps                 (F) = absl, ANTLR, APR, APR-util, arpack-ng, Autoconf, Automake, Autotools, backports.weakref, Bazel, binutils, Bison, bokeh, byacc, bzip2, cairo, cloudpickle, configurable-http-proxy, Coreutils, Cube, CUDA, cuDNN, cURL, DB, Doxygen, Eigen, expat, flex, FLTK, fontconfig, freetype, funcsigs, gc, GCCcore, gettext, GL2PS, GLib, glmnet, GLPK, GMP, gnuplot, go, gperf, GPGME, GraphicsMagick, groff, GTS, guile, help2man, hwloc, inputproto, IPython, JasPer, jemalloc, kbproto, Libassuan, libcerf, libdrm, libevent, libfabric, libffi, libgd, libGLU, libgpuarray, libiberty, libjpeg-turbo, libjpeg-turbo, libpciaccess, Libpgp-error, libpng, libpthread-stubs, libQGLViewer, libreadline, libsodium, libspatialindex, LibTIFF, libtool, libunistring, libunwind, libutempter, libX11, libXau, libxcb, libXdmcp, libXext, libxml2, libXrender, libxshmfence, libyaml, LLVM, LOKI, Loki, LVM2, M4, make, makeinfo, Mako, Mesa, minieigen, mock, mxml, NASM, NASM, ncurses, nettle, networkx, nodejs, nose-parameterized, numactl, OPARI2, OpenMPI, OpenPGM, parameterized, PCRE, PDT, Perl, PIL, Pillow, pixman, pkg-config, ploticus, PMIx, popt, prereq, protobuf, protobuf-core, PyGTS, PyQt, Python-bare, Python-Xlib, PyYAML, PyZMQ, Qhull, qrupdate, Qt, renderproto, runc, scikit-image, scikit-learn, SCons, SCOTCH, Serf, SIP, SQLite, SWIG, Szip, Tcl, Tk, UCX, UDUNITS, UnZip, util-linux, Werkzeug, wheel, X11, xcb-proto, xextproto, xorg-macros, xproto, xtrans, XZ, ZeroMQ, zlib, zstd
hide-toolchains           (F) = CrayCCE, CrayGNU, CrayIntel, CrayPGI, GCCcore, gmvapich2, gmvolf, foss, fosscuda, gompi
include-easyblocks        (E) = /apps/common/UES/jenkins/production/easybuild/easyblocks/\*.py
installpath               (E) = /users/lucamar/easybuild/pilatus
module-naming-scheme      (E) = HierarchicalMNS
optarch                   (E) = x86-rome
packagepath               (E) = /users/lucamar/easybuild/pilatus/packages
prefix                    (E) = /users/lucamar/easybuild/pilatus
repositorypath            (E) = /users/lucamar/easybuild/pilatus/ebfiles\_repo
robot-paths               (E) = /apps/common/UES/jenkins/production/easybuild/easyconfigs/, /apps/common/UES/easybuild/software/EasyBuild/4.3.4/easybuild/easyconfigs
sourcepath                (E) = /apps/common/easybuild/sources
tmpdir                    (E) = /run/user/21827/easybuild/tmp
```

---

## Configuration options

As reported in the output of the command `eb --show-config`, the configuration items labeled with `(E)` 
are defined by an environment variable of the form `EASYBUILD_<item>`, where `item` is in uppercase letters. 

Therefore the buildpath is defined by the variable `EASYBUILD_BUILDPATH`, whereas the prefix that defines 
the installpath of the modules created by EasyBuild is defined by `EASYBUILD_PREFIX`. 

You can change these configuration items editing the corresponding environment variable. 

---

## Choosing your installation folder

You can override the default installation folder by exporting the environment variables listed below, 
before loading the EasyBuild modulefile:
```
export EASYBUILD_PREFIX=/your/preferred/installation/folder
module load EasyBuild-custom
```

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

eb -S <program_name>

Please note that on Cray systems you can use the configuration files that rely of a Cray toolchain, 
which you will find in the configuration filename (`eb -S <name> | grep Cray`). 

You will be able to load the modules created by EasyBuild in the folder defined by the `EASYBUILD_PREFIX` 
variable using the following commands:
```
module use $EASYBUILD_PREFIX/modules/all
module load <modulename>/version
```

The command module use will prepend the selected folder to your MODULEPATH environment variable, 
therefore you will see the new modules with module avail. Please note that by default `EASYBUILD_PREFIX` 
is set to a folder inside your `$HOME`, however the `$HOME` folder is by default not readable by other users. 

Therefore if you want to make your builds available to your group, then you need to allow read-only access 
to other members of your group using the command `chmod g+rx $HOME`.

*[[next: Live Demo]](live_demo.md)*
