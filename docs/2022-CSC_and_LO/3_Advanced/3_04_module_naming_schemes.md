# Module naming schemes

*[[back: Submitting installations as Slurm jobs]](3_03_slurm_jobs.md)*

---

Up until now we have used the naming scheme in use on LUMI which is for many practical purposes
is indistinguishable from the default EasyBuild naming scheme (`EasyBuildMNS`).
It produces module files with names that closely resemble to the names of the
corresponding easyconfig files.
For example, when installing `zlib-1.2.11-cpeGNU-21.12.eb` the generated module was named 
`zlib/1.2.11-cpeGNU-21.12`.

EasyBuild supports several different module naming schemes:

```shell
$ eb --avail-module-naming-schemes
List of supported module naming schemes:
        EasyBuildMNS
        LUMI_FlatMNS
        MigrateFromEBToHMNS
        HierarchicalMNS
        CategorizedHMNS
        CategorizedModuleNamingScheme
```

In this part of the tutorial we will take a closer look at `HierarchicalMNS`,
which is the standard **hierarchical** module naming scheme included with EasyBuild.

We will also take a quick look at implementing our own custom module naming scheme.

## Flat vs hierarchical

!!! Note 

    This text is very much based on the generic EasyBuild tutorials as we cannot demonstrate
    all aspects on LUMI as it is configured today.

    On LUMI, the complete module scheme is partly hierarchical, but EasyBuild uses a flat naming
    scheme. The two levels in the hierarchy that are present to deal with different versions of
    the software stack and the various types of compute nodes, are not managed by EasyBuild.

The default module naming scheme `EasyBuildMNS` 
and the custom `LUMI_FlatMNS` naming scheme are both examples of regular *"flat"* 
module naming schemes, which are characterized by:

-    all module files are directly available for loading;
-    each module name uniquely identifies a particular installation;

In contrast, a *hierarchical* module naming scheme
consists of a *hierarchy* of module files. 
A fairly typical 3-level schme (``Core``, ``Compiler`` and ``MPI``) has been
discussed in the [section on Lmod](../1_Intro/1_02_Lmod#lmod-hierarchy).
This typical Lmod hierarcny would map very well on the EasyBuild common toolchains.

In fact, for the example

<div align="center"><img src="../img/hmns.png" width="60%"/></div>

software at the ``Core`` level would be installed with the ``GCCcore`` and ``SYSTEM``
toolchains. Software at the ``Compiler`` level would be installed with the ``GCC``
toolchain, while software at the ``MPI`` level after loading the ``OpenMPI`` module
would be installed using the regular ``foss`` toolchain or the ``gompi`` toolchain
(see the diagram in the 
["Common toolchains" section of the page on terminology](../1_Intro/1_05_terminology/#common-toolchains)).

On LUMI, where software is installed through the Cray Programming Environment with no real choice of
MPI implementation, a two-level arrangement would still make a lot of sense, with at the ``Core`` level
all software compiled with the SYSTEM toolchain while there could be a ``PrgEnv`` level for software
compiled with a particula programming enviornment aka cepGNU/cpeCray/cpeAOCC toolchain. Such a scheme
is used on the Cray systems at CSCS.

To recap, the characteristics of a module hierarchy are:

* not all module files are directly available for loading;
* some modules serve as a gateway to more modules;
* to access some software installations you will first need to load one or more gateway modules in order
  to use them;

You can probably think of other ways to organize module files in a hierarchical module tree, but here 
we will stick to the standard core / compiler / MPI hierarchy.

### Pros & cons

So why go through all this trouble of organizing modules hierarchically?

There are a couple of advantages to this approach:

* shorter module names (or at least for the version part of the name);
* less overwhelming list of available modules;
* only compatible modules can be loaded together;

However, the are some minor disadvantages too:

* not all existing modules are directly visible, so users have to learn how to find
  modules using ``module spider`` etc.;
* gateway modules may have little meaning to end users;

#### Length of module names

When using a flat module naming scheme, module names can be fairly long and perhaps confusing. For a `HDF5` installation 
with the EasyBuild common toolchains for example,
one might have `HDF5/1.10.6-gompi-2020a` as module name. The `-gompi-2020a` part of the name refers to the toolchain that was
used for this installation, but it may be confusing to some people (what kind of Pokémon is a "gompi"?!).

In the example module hierarchy shown above, the module for `HDF5` could simply be named `HDF5/1.10.6` which is basically the bare
essentials: software name and version. That's way better, nice and clean!

#### Amount of available modules

The output of "`module avail`" can be quite overwhelming if lots of module files
are installed and a flat module naming scheme is used, since *all* modules are
*always* available.
EasyBuild makes it very easy to install lots of software,
so the number of installed modules can easily grow into the hundreds or even thousands...

This often explosive growth of modules is less of an issue when using a hierarchical module naming scheme, since
initially only a small set of modules are available, and relatively limited
groups of additional modules become available as gateway modules are loaded.

#### Loading compatible modules

Since all modules are available at once when using a flat module naming scheme, you can easily load
modules together that are not compatible with each other.

Imagine loading two modules that were built with a different compiler toolchain (different compiler,
different MPI library). That's likely to end in tears, unless you have the necessary technical expertise
to fully understand what is going on, *and* you are being very careful...

In a module hierarchy this can be prevented, since modules for software that were installed with a
different compiler and/or a different MPI library are located in a different part of the module hierarchy,
and so these modules can not be loaded together easily.


#### Visibility of existing modules

One downside of a module hierarchy is that not all existing modules are directly available for loading
or are even *visible* to the user, since the output of "`module avail`" only shows a subset of all modules.

As we have discussed in [the Lmod section](../LMOD). 
[Lmod](https://lmod.readthedocs.io) provides a powerful solution to search for modules through the
``module spider`` and to some extent also the ``module keyword`` commands. 
So as long as the end users are
aware of this additional command, it should not be difficult to discover which software installations exist
and how they can be accessed. The "`module spider`" command will inform the user which of the gateway modules
need to be loaded in order to load a specific module file.

#### Semantics of gateway modules

An additional potential problem of a module hierarchy is that the semantics of the gateway modules may not be clear
to end users. They may wonder why they need to pick a specific compiler and MPI library, or which of the
available options is the best one. Maybe they are not even aware what exactly a "compiler" is, or how it is
relevant to the software they need in their bioinformatics pipeline...

This can be partially resolved by loading a default compiler and MPI module so a particular set of modules
is available right after login, which could be the ones used in the most recent toolchain, or the
recommended versions. More experienced users could then leverage the "`module spider`" command to navigate
the module hierarchy.

On LUMI this would mean loading a default software stack, but due to the the default modules are currently
loaded on LUMI this was not possible to accomplish without losing other functionality of the module tree.

## Using a custom module naming scheme

Next to the module naming schemes that are included with EasyBuild,
you can also define your own module naming scheme (MNS), and configure EasyBuild to use it
(which is eactly what has been done on LUMI to remove a feature of the default ``EasyBuildMNS`` scheme
that we do not use).

### Implementation

To use a custom module naming scheme, you need to implement a Python module file,
where you define a Python class that derives from the general [``ModuleNamingScheme``](https://docs.easybuild.io/en/latest/api/easybuild.tools.module_naming_scheme.mns.html#easybuild.tools.module_naming_scheme.mns.ModuleNamingScheme) class.

For a flat module naming scheme, it is sufficient to implement the ``det_full_module_name`` method,
which should return a string value (the full module name).
You may also need to customize the ``is_short_modname_for`` method, which verifies whether
a given (short) module name is for the software with a particular given name (or not).

The argument provided to ``det_full_module_name`` can be a small Python dictionary which only specifies
the value of a handful of easyconfig parameters (`name`, `version`, `toolchain`, and `versionsuffix`),
or an ``EasyConfig`` instance which represents a parsed easyconfig file and contains values for *all*
known easyconfig parameters.

For simple module naming schemes, just have ``name``, ``version``, ``toolchain``, and ``versionsuffix``
available is sufficient. If it is not, you can list which additional easyconfig parameters are required for
your module naming scheme via a class constant ``REQUIRED_KEYS``.

A fairly straightforward example of a *flat* module name scheme is the default EasyBuild module naming scheme
[``EasyBuildMNS``](https://github.com/easybuilders/easybuild-framework/blob/main/easybuild/tools/module_naming_scheme/easybuild_mns.py).

For a *hierarchical* module naming scheme, various additional methods have to be implemented.

Some of these, like ``det_module_subdir`` and ``det_short_module_name``, determine which part of
the (full) module name determines the location of the module in the module hierarchy, and which part
is the user-facing (or "short") module name. Others, like ``det_modpath_extensions``,
determine which modules are *gateway* modules that open up an additional level of the hierarchy
(by *extending* the ``$MODULEPATH``).

A typical example of a hierarchical module naming scheme is [``HierarchicalMNS``](https://github.com/easybuilders/easybuild-framework/blob/main/easybuild/tools/module_naming_scheme/hierarchical_mns.py) that comes with EasyBuild (which is quite complex because it includes quite a bit of special handling for particular compiler
toolchains), which implements the traditional ``Core``-``Compiler``-``MPI`` module hierarchy we discussed
above.

### Configuring EasyBuild

To let EasyBuild use a custom module naming scheme, you need to:

* specify the path to the Python module file implementing it via the ``include-module-naming-schemes``
  EasyBuild configuration option;

* indicate that you also want to *use* this custom module naming scheme via the ``module-naming-scheme``
  EasyBuild configuration option.

For example:

```shell
export EASYBUILD_INCLUDE_MODULE_NAMING_SCHEMES=$HOME/easybuild/example_mns.py
export EASYBUILD_MODULE_NAMING_SCHEME=ExampleMNS
```

#### Example custom module naming scheme

Here is an example of a custom module naming scheme, where:

* the ``versionsuffix`` goes directly after the ``version``;
* all dashes are replaced by underscores;
* all module names are lowercase;

Note that we also need to customise the ``is_short_modname_for`` method,
to make sure it returns ``True`` when the EasyBuild framework checks whether
``scipy_bundle/2020.11_foss_2020b`` is a module name for ``SciPy-bundle``.

```python
import os

from easybuild.tools.module_naming_scheme.mns import ModuleNamingScheme


class ExampleMNS(ModuleNamingScheme):

    REQUIRED_KEYS = ['name', 'version', 'versionsuffix', 'toolchain']

    def det_full_module_name(self, ec):
        """
        Determine full module name:
        - all lowercase
        - replace all dashes with underscores
        """
        parts = [ec['version']]

        # versionsuffix directly after version (but only if it's not empty)
        if ec['versionsuffix']:
            parts.append(ec['versionsuffix'])

        # only add toolchain name/version for non-system toolchain
        tc = ec['toolchain']
        if tc['name'].lower() != 'system':
            parts.extend([tc['name'], tc['version']])

        modname = ec['name'] + '/' + '_'.join(parts)

        modname = modname.replace('-', '_').replace('__', '_')

        return modname.lower()

    def is_short_modname_for(self, short_modname, name):
        """Determine whether short module name is a module for the software with specified name."""
        return short_modname.startswith(name.lower().replace('-', '_') + '/')
```

We can see what the module names with this module naming scheme would like like via ``eb -D``.
E.g., for the common toolchains (the example will not work on LUMI as the default easyconfig
files are not in the robot- and the search path):

```
$ eb SciPy-bundle-2020.11-foss-2020b-Python-2.7.18.eb -D
 ...
 * [ ] $CFGS/g/GCC/GCC-10.2.0.eb (module: gcc/10.2.0)
 ...
 * [ ] $CFGS/p/Python/Python-2.7.18-GCCcore-10.2.0.eb (module: python/2.7.18_gcccore_10.2.0)
 ...
 * [ ] $CFGS/o/OpenMPI/OpenMPI-4.0.5-GCC-10.2.0.eb (module: openmpi/4.0.5_gcc_10.2.0)
 ...
 * [ ] $CFGS/s/SciPy-bundle/SciPy-bundle-2020.03-foss-2020a-Python-2.7.18.eb (module: scipy_bundle/2020.03_python_2.7.18_foss_2020a)
```

## Example module hierarchy: HDF5

!!! Warning "Example not suitable for LUMI"
    **This exercise is meant for a system where the common toolchains can be used and requires an
    indpendent EasyBuild installation in your personal file space**,
    because EasyBuild will try to copy the installation log file to each installation directory.

Now that we know more about hierarchical module naming schemes,
let us see how EasyBuild can help us with generating a hierarchical module tree.

In this example we will use EasyBuild to generate modules organised in a hierarchy
for some of the software that is already installed in the prepared environment.

The good news is that the existing installations can be reused. There is absolutely no need
to reinstall the software, we are just creating a different "view" on these software installations.

### Preparing the environment

Before running EasyBuild to generate a hierarchical module tree, we have to be a bit careful
with preparing our environment.

**We must absolutely avoid mixing modules from a flat and hierarchical module naming scheme!**

Some module files will have the same name in both module trees (like `GCC/10.2.0` for example),
but their contents will be different.
Mixing modules from a flat and hierarchical module tree *will* trigger problems...

So we have to make sure that the module files we already have in `/easybuild` are *not* visible.
The easiest way to do this is to unload all modules (using "`module purge`")
and resetting the module search path to be empty, which we can do with "`module unuse $MODULEPATH`".

```shell
module purge
module unuse $MODULEPATH
```

In this part of the tutorial, we are assuming you are *not* using an EasyBuild installation provided through
a module. We have just made all modules unavailable, so we would have to first
install EasyBuild again in our hierarchical module tree before we can continue.

**We strongly recommend using an EasyBuild installation that was [installed via "`pip install`"
or "`pip3 install`"](../1_Intro/1_06_installation#method-1-using-pip) in this part of the tutorial.**

An easy way to do this is in the prepared environment is to run:

```shell
pip3 install --user easybuild
export PATH=$HOME/.local/bin:$PATH
export EB_PYTHON=python3
```

### Configuring EasyBuild

First of all, we need to make sure that EasyBuild is properly configured.
We can do this by defining this set of environment variables:

```shell
export EASYBUILD_PREFIX=$HOME/easybuild
export EASYBUILD_BUILDPATH=/tmp/$USER
export EASYBUILD_INSTALLPATH_SOFTWARE=/easybuild/software
export EASYBUILD_MODULE_NAMING_SCHEME=HierarchicalMNS
export EASYBUILD_INSTALLPATH_MODULES=$HOME/hmns/modules
```

To make sure we didn't make any silly mistakes, we double check using `eb --show-config`:


```shell
$ eb --show-config
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
buildpath            (E) = /tmp/example
containerpath        (E) = /home/example/easybuild/containers
installpath          (E) = /home/example/easybuild
installpath-modules  (E) = /home/example/hmns/modules
installpath-software (E) = /easybuild/software
module-naming-scheme (E) = HierarchicalMNS
packagepath          (E) = /home/example/easybuild/packages
prefix               (E) = /home/example/easybuild
repositorypath       (E) = /home/example/easybuild/ebfiles_repo
robot-paths          (D) = /home/example/.local/easybuild/easyconfigs
sourcepath           (E) = /home/example/easybuild/sources
```

There are a couple of things worth pointing out here:

* We have defined the `module-naming-scheme` configuration setting to `HierarchicalMNS`,
  which makes EasyBuild use the included standard hierarchical module naming scheme (the classic
  core / compiler / MPI one we discussed above).
* We have specified *different* locations for the software (via `installpath-software`)
  and the module files (via `installpath-modules`). This is important because we want to
  reuse the software that is already installed in `/easybuild/software` while we want to
  generate an entirely new module tree for it (in `$HOME/hmns/modules`).

The other configuration settings are the same as before, and mostly irrelevant for this example.

### Generating modules for HDF5

Let us now generate a hierarchical module tree for `HDF5` and all of its dependencies,
including the toolchain. That sounds complicated, and it sort of is since there are
a lot of details you have to get right for the module hierarchy to works as intended,
but EasyBuild can do all the hard work for us.

The steps we will have to go through are:

* Tell EasyBuild we want to "install" the `HDF5-1.10.7-gompi-2020b.eb` easyconfig file;
* Enable dependency resolution via `--robot`;
* Assuming the software would have been installed already with the default naming scheme
  in a different module directory, instruct EasyBuild to only generate the module files, 
  not to install the software (since it is
  there already in `/easybuild/software`), via the `--module-only` option.

These steps translate to this single `eb` command:

```
$ eb HDF5-1.10.7-gompi-2020b.eb --robot --module-only
...
== building and installing MPI/GCC/10.2.0/OpenMPI/4.0.5/HDF5/1.10.7...
...
== sanity checking...
== cleaning up [skipped]
== creating module...
...
== COMPLETED: Installation ended successfully (took 9 sec)
...
== Build succeeded for 41 out of 41
```

This should take a couple of minutes in total, for generating 41 modules.
Remember that this also includes generating module files for the toolchain and
all of its components.

In addition, there is a bit more going on one that just generating module files,
since the sanity check step is still being run for each of the installations
when using `--module-only` to ensure the installation is actually functional.
After all, there is no point in generating a module for an obviously broken
installation...

### Loading the HDF5 module

After generating the hierarchical module tree for HDF5, how do we access the HDF5 installation through it?

Here's what the module tree looks like on disk:

```
$ ls $HOME/hmns/modules/all
Compiler  Core  MPI
```

Those are basically the 3 levels in the module hierarchy we showed in our example earlier.

The starting point is the top level of the module hierarchy named `Core`:

```
module use $HOME/hmns/modules/all/Core
```

Let us see what that gives us in terms of available modules:

```
$ module avail

--------------------- /home/easybuild/hmns/modules/all/Core ---------------------
   Bison/3.5.3        GCCcore/10.2.0    flex/2.6.4      help2man/1.47.4
   Bison/3.7.1 (D)    M4/1.4.18         gettext/0.21    ncurses/6.2
   GCC/10.2.0         binutils/2.35     gompi/2020b     zlib/1.2.11
```


Nice and short module names, but only a limited set of them.

We know a module file exists for `HDF5`, but we can't see it yet (and hence
we can't load it either).

```
$ module avail HDF5
No module(s) or extension(s) found!
Use "module spider" to find all possible modules and extensions.
```

Let us see if `module spider` is of any help, as "`module avail`" so kindly suggests:

```
$ module spider HDF5
...

    You will need to load all module(s) on any one of the lines below
    before the "HDF5/1.10.7" module is available to load.

      GCC/10.2.0  OpenMPI/4.0.5
```

This tells us we need to load two gateway modules before we can load the module
for HDF5.

Let us start with loading the `GCC` compiler module:

```
module load GCC/10.2.0
```

And then check again which modules are available:

```
$ module avail

-------------- /home/easybuild/hmns/modules/all/Compiler/GCC/10.2.0 --------------
   OpenMPI/4.0.5

------------ /home/easybuild/hmns/modules/all/Compiler/GCCcore/10.2.0 ------------
   Autoconf/2.69             UCX/1.9.0                 libpciaccess/0.16
   ...
   Szip/2.1.1                libfabric/1.11.0          zlib/1.2.11        (L,D)
   Autoconf/2.69         XZ/5.2.5                libtool/2.4.6

--------------------- /home/easybuild/hmns/modules/all/Core ---------------------
   Bison/3.5.3        GCCcore/10.2.0 (L)  flex/2.6.4      help2man/1.47.4
   Bison/3.7.1 (D)    M4/1.4.18           gettext/0.21    ncurses/6.2
   GCC/10.2.0  (L)    binutils/2.35       gompi/2020b     zlib/1.2.11
```

Good news, we now have additional modules available!

The compiler level of our hierarchy actually consists of two directories here: `Compiler/GCCcore/10.2.0`
and `Compiler/GCC/10.2.0`. The modules in the `GCCcore` directory are ones we can use in other compiler
toolchains that use GCC 10.2.0 as a base compiler (the details of that are out of scope here).

The module we are interested in is `OpenMPI/4.0.5`, which is another gateway module.

Remember that the "`module spider`" output told us that there does indeed exist a module for `HDF5`, but that
we need to load *both* the `GCC/10.2.0` and `OpenMPI/4.0.5` modules first.

So, let us do exactly that (remember that `GCC/10.2.0` is already loaded):

```
module load OpenMPI/4.0.5
```

If you now check the output of "`module avail`" again, you should see the `HDF5/1.10.7` module:

```
$ module avail

-------- /home/easybuild/hmns/modules/all/MPI/GCC/10.2.0/OpenMPI/4.0.5 -------
   HDF5/1.10.7

------------ /home/easybuild/hmns/modules/all/Compiler/GCC/10.2.0 ------------
   OpenMPI/4.0.5 (L)

...
```

To use HDF5, we need to load this `HDF5/1.10.7` module. We can verify that the installation works
using one of the commands provided by HDF5, `h5dump` for example:

```
module load HDF5/1.10.7
```

```
$ h5dump --version
h5dump: Version 1.10.7
```

If you now check which modules are loaded via "`module list`", you will notice that all module names
and nice and short now, which is one of the advantages of using a hierarchical module tree:

```shell
$ module list

Currently Loaded Modules:
  1) GCCcore/10.2.0   5) numactl/2.0.13      9) hwloc/2.2.0       13) PMIx/3.1.5
  2) zlib/1.2.11      6) XZ/5.2.5           10) libevent/2.1.12   14) OpenMPI/4.0.5
  3) binutils/2.35    7) libxml2/2.9.10     11) UCX/1.9.0         15) Szip/2.1.1
  4) GCC/10.2.0       8) libpciaccess/0.16  12) libfabric/1.11.0  16) HDF5/1.10.7
```


---

*[[next: GitHub integration]](3_05_github_integration.md)*
