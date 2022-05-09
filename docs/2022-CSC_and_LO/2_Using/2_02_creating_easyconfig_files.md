# Creating easyconfig files

*[[back: Troubleshooting]](2_01_troubleshooting.md)*

---

We already know how to install easyconfig files that are provided by LUMI,
but what about installing software for which no easyconfig is available yet,
or for which we need to adapt an existing easyconfig?

To do this we will need to **create additional easyconfig files**,
since every software installation performed by EasyBuild is done based on an easyconfig file.

In this part of the tutorial we will look at the guts of easyconfig files and even create some ourselves!

## Easyconfigs vs easyblocks

Before we dive into writing [easyconfig files](../../1_Intro/1_05_terminology/#easyconfig-files),
let us take a brief look at how they relate to [easyblocks](../../1_Intro/1_05_terminology/#easyblocks).

As we discussed [earlier](../../1_Intro/1_05_terminology/#terminology), an easyconfig file (`*.eb`) is required
for each installation
performed by EasyBuild which specifies the details of the installation (which software
version, toolchain, etc.), while the installation procedure is implemented
in an easyblock (a Python module).

When can we leverage a *generic easyblock*, perhaps via a "fat" easyconfig file that includes
a lot of carefully defined easyconfig parameters, and when should we use a minimal easyconfig file
together with a custom *software-specific* easyblock?

This is not an easy question to answer in a general sense, since it depends on several factors:
the complexity of the software you want to get installed, how much flexibility you want,
how "intelligent" the installation procedure should be with respect to the compiler toolchain and dependencies
that are used for the installation, whether you want an easyconfig that is more user-focused (with easy-to-understand
parameters) or one that is more focused towards people who understand installation commands, etc.

In a nutshell, custom software-specific easyblocks are "do once and forget": they are central solution to peculiarities in the installation procedure of a particular software package. However, they also hide a lot from direct view, so if things go
wrong, it is often harder to debug the exact problem. And since a single easyblock has to cover
multiple software versions, multiple toolchains and multiple possible configurations of the package,
they are often harder to develop and certainly harder to test. As a result many of the easyblocks 
included with EasyBuild work poorly on HPE Cray systems, e.g., because they want to add compiler flags
specific for a certain compiler and don't recognise the Cray compilers.

Reasons to consider implementing a software-specific easyblock rather than using a generic easyblock include:

-   'critical' values for easyconfig parameters required to make installation succeed;
    *For example, the [easyblock for bowtie2](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/b/bowtie2.py)
    defines a number of variables used in the Makefile are specified on the make command line to ensure that the right
    compilers are used.*
-   toolchain-specific aspects of the build and installation procedure (e.g., configure options);  
    *For example, the [easyblock for CP2K](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/c/cp2k.py) 
    will add several compiler options when compiling with gcc and gfortran, including the infamous
    `-fallow-argument-mismatch` which is required from gfortran 10 on for many older codes.*
-   custom (configure) options for dependencies;  
    *For example, the [easyblock for VMD](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/v/vmd.py)
    will add configure options depending on the dependency list of the package.*
-   interactive commands that need to be run;  
    *For example: The [easyblock for maple](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/m/maple.py) 
    responds to a number of interactive questions.* 
-   having to create or adjust specific (configuration) files;  
    *For example, the [easyblock for Siesta](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/s/siesta.py)
    edits one of the configuration files through regular expressions.*
-   'hackish' usage of a generic easyblock;
-   complex or very non-standard installation procedure;  
    *For example, the [easyblock to install the gcc compilers from source](https://github.com/easybuilders/easybuild-easyblocks/blob/develop/easybuild/easyblocks/g/gcc.py),
    bootstrapping with the system compiler and then re-installing with itself.* 

For implementing easyblocks we refer to the 
["Implementing easyblocks" section of this tutorial](../2_04_implementing_easyblocks)
and the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Implementing-easyblocks.html).

## Writing easyconfig files

Writing an easyconfig file boils down to defining a set of easyconfig parameters in a text file,
which we give a '`.eb`' extension by convention. The name of an easyconfig file doesn't matter
when using it directly to install software, but it does matter when EasyBuild needs to find it
to resolve a dependency for example (as we [discussed earlier](../../1_Intro/1_08_basic_usage/#easyconfig-filenames)).

The syntax for easyconfig files is *Python syntax*: you are basically defining a bunch of Python variables
that correspond to easyconfig parameters.

The order in which the easyconfig parameters are defined doesn't matter, but we generally try to stick to a particular
order which roughly corresponds to the order in which the easyconfig parameters are used during the installation.
That is mostly helpful for humans staring at easyconfig files or comparing them.

### Mandatory parameters

A limited number of easyconfig parameters are *mandatory*, they must be defined in every easyconfig file:

-   `name`: the name of the software to install;
-   `version`: the version of the software to install;
-   `homepage`: a URL to the website of the software;
-   `description`: a description of the software;
-   `toolchain`: the compiler toolchain to use for the installation;

#### `name`, `version`

It should be no surprise that specifying the name and version of the software you want to install is mandatory.
This information may influence the value of several other easyconfig parameters (like the name of the source file), and is also used to the determine the name of the module file to install.

```python
name = 'example'
version = '1.0'
```

#### `homepage`, `description`

The homepage and description are included in the generated module file for the installation.
That way the "`module show`" command provides some useful high-level information about the installation.

```python
homepage = 'https://example.org'
description = "This is just an example."
```

Usually it does not matter whether you use single or double quotes to specify string values.
There are cases where it is important to use
the right type of quotes however, we will get back to that later (keep it in mind for the exercises!).

For multi-line descriptions, you will need to use "triple quoting" (which is standard Python syntax):

```python
description = """This is an example
 of a multi-line description.
 It is spread across multiple lines."""
```

If no homepage is known for the package, the convention in the EasyBuild community is to use 
`(none)` as the value.

The `description` field is used in two different places in the LUA module file generated by
EasyBuild:
-   In the help block, for the first section of the help information
-   If there is no `whatis` parameter in the easyconfig file, it is also used to generate
    a whatis-command with the description in the module file.

*Note:* We ask people who contribute easyconfigs to LUMI to instead use a decent description
that is useful in the help information, and to specify a short description via the `whatis`
parameter:

```python
whatis = ['Description: Blosc is an extremely fast, multi-threaded, meta-compressor library']
```

Note that in this case the word "Description:" has to be explicitly specified.


#### `toolchain`

EasyBuild also requires that the [compiler toolchain](../../1_Intro/1_05_terminology/#toolchains) is specified, via the `toolchain`
easyconfig parameter.

This can either be the [`system` toolchain](../../1_Intro/1_05_terminology/#system-toolchain), for which a constant named `SYSTEM` is available:

```python
toolchain = SYSTEM
```

Usually we specify a 'proper' toolchain like the `cpeGNU/21.12` toolchain we have used bvefore. 
The name and version of the toolchain can be specified using a small Python dictionary,
for example:

```python
toolchain = {'name': 'cpeGNU', 'version': '21.12'}
```

### Commonly used parameters

You will often need to specify additional easyconfig parameters to get something useful done.
We will cover the most commonly used ones here, but keep in mind that these are *not* mandatory.

A full overview of all known easyconfig parameters can be obtained via "`eb --avail-easyconfig-params`"
or just "`eb -a`" for short, or can be consulted in the [EasyBuild documentation](https://docs.easybuild.io/en/latest/version-specific/easyconfig_parameters.html).

#### Sources, patches, and checksums

In most easyconfig files you will see that a list of source files is specified via the `sources`
easyconfig parameter, usually combined
with one or more URLs where these sources can be downloaded specified via `source_urls`.
There also may be patch files listed (specified via `patches`),
and checksums for both the source files and patches (specified via `checksums`).

The `sources` easyconfig parameter is commonly defined but it is *not* mandatory,
because some easyconfig files only specify bundles of software packages and hence only
serve to generate a module file.

Here is an example of how these easyconfig parameters can be specified:

```python
source_urls = [
    'https://example.org/download/',
    'https://example.org/download/archive/',
]
sources = ['example-1.0-src.tar.gz']
patches = ['example-fix.patch']
checksums = [
    '9febae18533d035ac688d977cb2ca050e6ca8379311d7a14490ad1ef948d45fa',
    '864395d648ad9a5b75d1a745c8ef82b78421d571584037560a22a581ed7a261c',
]
```

Each of these require a *list* of values, so even if there is only a single source file or download URL
you must use square brackets as shown in the example. The default value for each of these is an empty list (`[]`).

Some things worth pointing out here:

* The download URLs specified via `source_urls` do *not* include the name of the file, that is added
  automatically by EasyBuild when it tries to download the file (only if it's not available already.)
* If multiple download URLs are specified, they are each tried once in order until the download of the source file was
  successful. This can be useful to include backup locations where source files can be downloaded from.
* Names of source files and patches should not include hardcoded software versions, they usually use a
  template value like `%(version)s` instead:
  ```python
  sources = ['example-%(version)s-src.tar.gz']
  ```
  EasyBuild will use the value of the `version` easyconfig parameter to determine the actual name of the source
  file. This way the software version is only specified in one place and the easyconfig file is easier to
  update to other software versions. A list of template values can be consulted via the EasyBuild command
  line via the `--avail-easyconfig-templates` option, or in the [EasyBuild documentation](https://docs.easybuild.io/en/latest/version-specific/easyconfig_templates.html).
* Source files can also be specified in ways other than just using a filename, see the 
  [EasyBuild documentation](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html#common-easyconfig-param-sources-alt) for more information.
  It is also possible to download a given commit from a GitHub repository.
* Specified checksums are usually SHA256 checksum values, but 
  [other types are also supported](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html?highlight=checksums#checksums).


#### Easyblock

The easyblock that should be used for the installation can be specified via the `easyblock` easyconfig parameter.

This is not mandatory however, because by default EasyBuild will determine the easyblock to use based on the
name of the software. If '`example`' is specified as software name, EasyBuild will try to locate a
software-specific easyblock named `EB_example` (in a Python module named `example.py`). Software-specific
easyblocks follow the convention that the class name starts with `'EB_`', followed by the software name
(where some characters are replaced, like '`-`' with '`_minus_`'). It is possible to use different
naming conventions for software-specific easyblocks, but then EasyBuild will not automatically detect
that there is one for the package and it will also need to be specified via the `easyblock` parameter.

**Generic easyblocks**

Usually the `easyblock` value is the name of a *generic* easyblock, if it is specified. The name of
a generic easyblock does *not* start with '`EB_`', so you can easily distinguish it from a software-specific
easyblock.

Here are a couple of commonly used generic easyblocks:

* `ConfigureMake`: implements the standard `./configure`, `make`, `make install` installation procedure;
* `CMakeMake`: same as `ConfigureMake`, but with `./configure` replaced with `cmake` for the configuration step;
* `PythonPackage`: implements the installation procedure for a single Python package, by default using
   "`python setup.py install`" but other methods like using "`pip install`" are also supported;
* `Bundle`: a simple generic easyblock to bundle a set of software packages together in a single installation directory;
* `PythonBundle`: a customized version of the `Bundle` generic easyblock to install a bundle of Python packages
  in a single installation directory;

A full overview of the available generic easyblocks is available in the [EasyBuild documentation](https://docs.easybuild.io/en/latest/version-specific/generic_easyblocks.html). You can also consult the output of
`eb --list-easyblocks`, which gives an overview of *all* known easyblocks, and how they relate to each other.

**Custom easyconfig parameters**

Most generic easyblocks provide additional easyconfig parameters to steer their behaviour.
You can consult these via "`eb -a --easyblock`" or just "`eb -a -e`", which results in an
additional "`EASYBLOCK-SPECIFIC`" section to be added. See the (partial) output of this command for example:

```shell
$ eb -a -e ConfigureMake
Available easyconfig parameters (* indicates specific to the ConfigureMake easyblock):
...
EASYBLOCK-SPECIFIC
------------------
build_cmd*              Build command to use [default: "make"]
build_type*             Value to provide to --build option of configure script, e.g., x86_64-pc-linux-gnu (determined by config.guess shipped with EasyBuild if None, False implies to leave it up to the configure script) [default: None]
configure_cmd*          Configure command to use [default: "./configure"]
configure_cmd_prefix*   Prefix to be glued before ./configure [default: ""]
host_type*              Value to provide to --host option of configure script, e.g., x86_64-pc-linux-gnu (determined by config.guess shipped with EasyBuild if None, False implies to leave it up to the configure script) [default: None]
install_cmd*            Build command to use [default: "make install"]
prefix_opt*             Prefix command line option for configure script ('--prefix=' if None) [default: None]
tar_config_opts*        Override tar settings as determined by configure. [default: False]
```

#### Dependencies

You will often need to list one or more [dependencies](../../1_Intro/1_05_terminology/#dependencies) that are required
to install or run the software.
We distinguish between two main different types of dependencies: runtime dependencies and build dependencies.

*Runtime dependencies* are required for using the installed software, and may also have to be available
during the installation. These dependencies can be specified via the `dependencies` easyconfig parameter.
EasyBuild will load the modules for these dependencies when setting up the build environment,
and will include load statements for them in the generated module file.

*Build dependencies* are only required during the installation of the software, not for using the
software once it is installed. The modules for these dependencies will be loaded in the build environment
set up by EasyBuild during the installation, but they will *not* be loaded by the generated module file.
You can specify build dependencies via the `builddependencies` easyconfig parameter.
One typical example of a build dependency is `CMake`, which is only needed for configuring
the build. On LUMI we define a `buildtools` module for each version of the `LUMI` software stack
which contains most popular build tools. This ensures that we use a consistent set of build tools
and that they do not change over the life time of a stack, also in case of OS upgrades, to 
increase the reproducibility of the build process

Here is a simple example of specifying dependencies:

```python
builddependencies = [
  ('buildtools', '%(toolchain_version)s', '', True)
]

dependencies = [
    ('Python', '3.8.2'),
    ('HDF5', '1.10.6'),
    ('SciPy-bundle', '2020.03', '-Python-%(pyver)s'),
]
```

Both `builddependencies` and `dependencies` require a list of tuples,
each of which specifying one dependency.
The name and version of a dependency is specified with a 2-tuple (a tuple with two string values).

In some cases additional information may have to be provided, as is shown in the example above for the `SciPy-bundle`
dependency where a 3rd value is specified corresponding to the `versionsuffix` value of this dependency.
If this is not specified, it is assumed to be the empty string (`''`). 

Note how we use the '`%(pyver)s'` template value in the `SciPy-bundle` dependency
specification, to avoid hardcoding the Python version in different places. (Though this
specific parameter is less useful on LUMI as we currently try to build on top of `cray-python`.)

The `buildtools` build dependency shows that there is a fourth parameter specifying the toolchain 
used for that dependency and is needed if that toolchain is different from the one used in the example.
As it is not possible to load several Cray toolchains together (they are not in a hierarchical relation)
the only useful value on LUMI is `True` which tells that `buildtools` is build with the `SYSTEM` 
toolchain. Here also we use a template, `%(toolchain_version)s` which - as its name suggests - expands
to the version of the toolchain, as we version our `buildtools` modules after the version of the Cray
toolchains for which they are intended. 

See also the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html#dependencies) 
for additional options on specifying dependencies. That page specifies two more dependency types:

* `hiddendependencies` are currently not used on LUMI, and if we would use them in the future, it will likely
  be through a way that does not require this parameter.
* `osdependencies` can be used to let EasyBuild check if certain needed OS packages are installed.
  See, e.g., the [easyconfigs for the `buildtools` package](https://github.com/Lumi-supercomputer/LUMI-SoftwareStack/tree/main/easybuild/easyconfigs/b/buildtools)
  on LUMI.


#### Version suffix

In some cases you may want to build a particular software package in different configurations, 
or include a label in the module name to highlight a particular aspect
of the installation.

The `versionsuffix` easyconfig parameter can be used for this purpose. 
The name of this parameter implies that this label will be added after the
software version (and toolchain label) in the standard module naming scheme.

If you are configuring the software to build with a particular non-default value,
you can indicate this as follows for example:

```python
versionsuffix = '-example-label'
```

This mechanism is used frequently to indicate that a software installation depends
on a particular version of Python, where the `%(pyver)s` template comes in useful again:

```python
versionsuffix = '-Python-%(pyver)s'
...
dependencies = [('Python', '2.7.18')]
```

Even though Python 2 is officially dead and
buried some scientific software still requires it, and mixing modules where
some use Python 2 and other use Python 3 doesn't work well.
The `versionsuffix` label is helpful to inform the user that a particular Python version is 
required by the installation.

#### Customizing configure, build, test, and install commands

When using a generic easyblock like `ConfigureMake` or `CMakeMake`, you will often
find yourself having to specify options to the configure, build, test, or install commands, or to inject additional commands right before them.

For this the following standard easyconfig parameters are available:

* `preconfigopts`: string value that is glued *before* the configure command;
* `configopts`: string value that is added *after* the configure command, which can be used to specify configuration options;

Equivalent easyconfig parameters are available for the `build`, `test` and `install` steps: `prebuildopts`, `buildopts`, `pretestopts`, `testopts`, `preinstallopts`, and `installopts`.

Here is a fictitious example of how they can be used:

```python
easyblock = 'ConfigureMake'
...
dependencies = [('HDF5', '1.10.6')]
...
configopts = '--enable-hdf5-support'

prebuildopts = 'export HDF5_PREFIX="$EBROOTHDF5" && '

installopts = "PREFIX='%(installdir)s'"
```
(again an imaginary example as on LUMI we advise to use the Cray-provided HDF5 modules.)

Here we are:

* Adding the `--enable-hdf5-support` configure option, to convince the `ConfigureMake` easyblock to run the following
  command during the configure step:
  ```shell
  ./configure --prefix ... --enable-hdf5-support
  ```
  (where the '`...`' represents the path to installation directory where the software should be installed).

* Specifying that an additional command has to be run before running `make` in the build step. We use '`&&`' to glue the
  command to the `make` command, so `make` will only be run if the command we specified ran correctly. So, the build step will run something like:
  ```shell
  export HDF5_PREFIX="$EBROOTHDF5" &&  make -j 4
  ```
  The '`4`' value passed to the `-j` option shown here, which specifies how many commands `make` can run in parallel, is automatically determined by EasyBuild based on the number of available cores (taking into account `ulimit` settings, and cpuset and cgroup restrictions).

* Passing the location where the software should be installed via the `PREFIX` argument to the `make install` command during the installation step. This results in the
  following command being run:
  ```shell
  make install PREFIX=...
  ```
  (where the '`...`' again represents the path to installation directory).
  Even though the
  installation directory is already specified in the configure command, it is
  apparently blatantly ignored by the software we are installing here, and we are expected to specify it
  this way instead. How rude!

The `$EBROOTHDF5` environment variable that we are using in `prebuildopts` corresponds to the path of
the installation directory of the HDF5 dependency. EasyBuild includes a statement
to define an `$EBROOT*` environment variable
like this in every environment module file it generates (see the output of "`module show HDF5`").

#### Sanity check

One seemingly trivial yet important aspect of the installation procedure that EasyBuild performs
is the sanity check step.

By default EasyBuild does a simple sanity check that verifies whether there is a non-empty `bin` subdirectory
in the installation, next to a non-empty `lib` or `lib64` directory (either is sufficient).

It is recommended to customize the sanity check and check for something more specific, like a particular
binary or directory, or making sure that a trivial command (like `example -V` or `example --help`)
runs correctly.

To specify a custom set of files and/or directories to check,
you can use the `sanity_check_paths` easyconfig parameter. The expected value is Python dictionary
with two keys: `files` and `dirs`. For example:

```python
sanity_check_paths = {
    'files': ['bin/example'],
    'dirs': ['examples/one', 'examples/two'],
}
```

In addition, you can specify one or more commands that should be working without a problem (that is, have a zero exit status) via the `sanity_check_commands` easyconfig parameter.
These commands will be run just like a user would: after loading the module that was generated for this installation.
Here is an example:

```python
sanity_check_commands = [
    "example --version",
    "example --help",
]
```


#### Module class

Finally, you will usually see the `moduleclass` easyconfig parameter to be defined as well, for example:

```python
moduleclass = 'lib'
```

This is done to categorize software, and it is used to group the generated module files into smaller sets 
([remember what we saw when installing software earlier](../../1_Intro/1_08_basic_usage/#using-installed-software)).

This is currently not used on LUMI since we feel that (a) it is not easy to explain to users how they can
then only make certain classes that are useful to them visible and more importantly (b) since it is not
always intuitive to decide which moduleclass should be used for a package, or from a user 's perspective,
in which category to look for a package.

## Generating tweaked easyconfigs

Sometimes you may want to install software that differs only slightly from an
existing easyconfig file, like a newer software version or using a different
compiler toolchain. Do we need to create an easyconfig file for this too?

We do, but EasyBuild does provide some help so you don't need to *manually*
create the easyconfig file. You can use one of the `--try-*` options provided
by the `eb` command to make EasyBuild *generate* a new easyconfig file based on
an existing one.

For example, to try installing a different software version you can use the `--try-software-version` option:

```shell
eb example-1.2.3.eb --try-software-version 1.2.4
```

Or, to try using a different compiler toolchain you can use `--try-toolchain`:

```shell
eb example-1.2.3-foss-2020b.eb --try-toolchain cpeCray,21.12
```

There is also a `--try`  option to change an arbitrary parameter in an easyconfig:

```shell
eb example-1.2.3-foss-2020b.eb --try-amend versionsuffix='-test'
```

Its general syntax is 

```
--try-amend=VAR=VALUE[,VALUE]
```

This option can be used multiple times also to make multiple changes.

It is important to keep in mind the *"try"* aspect here: while easyconfigs that
are generated by EasyBuild via a `--try-*` option often do work fine, there is
no strong guarantee they will. Newer software versions may come with changes to
the installation procedure, additional dependencies that are required, etc.
Using a different compiler toolchain may be as simple as just switching one for
another, but it may require additional changes to be made to configure options, for example.

The easyconfig files modified in this way will be stored in the `easybuild` subdirectory 
of the software installation directory and in the easyconfig archive that EasyBuild creates.

## Copying easyconfigs

One additional handy command line option we want to highlight is `--copy-ec`, which can be used to
copy easyconfig files to a specific location. That may sound trivial, but
keep in mind that you can specify easyconfigs to the `eb` command using only
the filename, and letting the robot search mechanism locate them.

So to copy an easyconfig file, we would have to use `eb --search` first to
get the full location to it, copy-paste that, and then use the `cp` command.

It is a lot easier with `--copy-ec`:

```shell
$ eb --copy-ec SAMtools-1.11-GCC-10.2.0.eb SAMtools.eb
...
SAMtools-1.10-GCC-10.2.0.eb copied to SAMtools.eb
```

If you omit the target location, the easyconfig file will simply be copied
to the current working directory, retaining the original filename.

You can copy multiple easyconfig files at once, as long as the target location
is an existing directory.

## Example

By means of example, we are going to puzzle together an easyconfig file to install the
example software package `eb-tutorial`.

The sources for `eb-tutorial` version 1.0.1 are available at:

```
https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/eb-tutorial-1.0.1.tar.gz
```

You can consult the unpacked sources at [https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/eb-tutorial-1.0.1](https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/eb-tutorial-1.0.1).

### Preparation

Make sure that a proper version of the `LUMI` software stack is loaded
(we recommend `LUMI/21.12` for the session for which this tutorial was designed)
and also `EasyBuild-user` is loaded to configure EasyBuild to install in
`$HOME/EasyBuild` or `$EBU_USER_PREFIX`.

``` shell
module load LUMI/21.12
module load EasyBuild-user`
```


### Easyblock

Let's start by getting the mandatory easyconfig parameters defined in the easyconfig file:

```python
name = 'eb-tutorial'
version = '1.0.1'

homepage = 'https://easybuilders.github.io/easybuild-tutorial'

whatis = [ 'Description: EasyBuild tutorial example']

description = """
This is a short C++ example program that can be build using CMake.
"""
```

Let's see what EasyBuild does with this very minimal easyconfig file:

```shell
$ eb eb-tutorial.eb
== Temporary log file in case of crash /run/user/XXXXXXXXX/easybuild/tmp/eb-k_82wotb/easybuild-wg0k_reb.log
ERROR: Failed to process easyconfig /pfs/lustrep4/users/XXXXXXXX/easybuild-tutorial-exercises/2022-CSC_and_LO-examples/2_02_example_eb-tutorial/eb-tutorial_v1.eb: 
No software-specific easyblock 'EB_eb_minus_tutorial' found for eb-tutorial
```

It is not mandatory to specify an easyblock in the easyconfig. However, in the absence of that
specification, EasyBuild goes looking for an application-specific easyblock with the standard name,
in this case `EB_eb_minus_tutorial`, which it does not have. Does that mean we have to implement an easyblock?

In this simple case it doesn't, since we can leverage one of the available *generic easyblocks*.
But, which one?

Build instructions are usually included in a `README` file, or in the documentation.
In this case, there's indeed a minimal 
[`README` file](https://github.com/easybuilders/easybuild-tutorial/blob/main/docs/files/eb-tutorial-1.0.1/README) 
available, which tells us that we should use the `cmake` command to configure the installation, followed by `make` and `make install`.

[We briefly discussed](#easyblock) a generic easyblock that does exactly this: `CMakeMake`.

```python
easyblock = 'CMakeMake'
```

The "`easyblock =`" line is usually at the top of the easyconfig file, but strictly speaking
the order of the parameter definitions doesn't matter (unless one is defined in terms of another one).


### Mandatory parameters

When trying this improved easyconfig file, EasyBuild will inform us that we failed to specify 
one of the mandatory easyconfig parameters: `toolchain`:

```
$ eb example.eb
== Temporary log file in case of crash /run/user/XXXXXXXXX/easybuild/tmp/eb-22om7hut/easybuild-ipozjipf.log
ERROR: Failed to process easyconfig /pfs/lustrep4/users/XXXXXXXX/easybuild-tutorial-exercises/2022-CSC_and_LO-examples/2_02_example_eb-tutorial/eb-tutorial_v2.eb: 
mandatory parameters not provided in pyheader: toolchain
```

We will use `cpeCray/21.12` as toolchain, so we also define the `toolchain` easyconfig parameter:

```python
toolchain = {'name': 'cpeCray', 'version': '21.12'}
```

In addition, we'll also specify the `moduleclass`.
This is not required, but it is usually set to a sensible value:

```python
moduleclass = 'tools'
```

The default value is '`base`', at least '`tools`' has *some* meaning.

### CMake build dependency

The `CMakeMake` easyblock needs the `cmake` command. On LUMI we are lucky as 
`cmake` is already installed in the OS. It may be a somewhat older version, but for this
program is is probably enough. Yet in general it is better to use sufficiently recent
build tools, and `cmake` is one of those tools that is typically entered as a build
dependency. After all, the less you rely on the OS, the more likely it becomes that
your easyconfig is useful for other sites also.

In the [section on Lmod](../../1_Intro/1_02_Lmod#module-extensions) we've already seen that on LUMI
the `cmake` command is available through the `buildtools` modules, and as discussed in
other examples on this page, LUMI has one for every `LUMI` software stack with its version
number the same as the stack and corresponding toolchains. It is a good practice to
add this module as a build dependency:

```python
builddependencies = [
  ('buildtools', '%(toolchain_version)s', '', True)
]
```

In a more traditional EasyBuild setup with the common toolchains, there is usually no need to specify
the toolchain for (build) dependencies. EasyBuild will automatically consider
[subtoolchains](../../1_Intro/1_05_terminology/#toolchains) compatible with the specified toolchain to locate 
modules for the dependencies. However, the Cray PE toolchains on LUMI are currently not part of
such a hierarchy and the `SYSTEM` toolchain we used for `buildtools` is not automatically considered
which is why we need the 4-element version of the dependency specification.

You can verify that EasyBuild now locates the dependency via `eb -D` (equivalent with `eb --dry-run`):

```
$ eb eb-tutorial.eb -D
 ...
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-common/buildtools/buildtools-21.12.eb (module: buildtools/21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/cpeCray/cpeCray-21.12.eb (module: cpeCray/21.12)
 * [ ] /pfs/lustrep4/users/kulust/easybuild-tutorial-exercises/2022-CSC_and_LO-examples/2_02_example_eb-tutorial/eb-tutorial_v4.eb (module: eb-tutorial/1.0.-cpeCray-21.12)
```

### Sources

If you try again after adding `buildtools` as a build dependency, you will see the installation fail again in the
configuration step. Inspecting the log file reveals this:

```
CMake Error: The source directory "/run/user/XXXXXXXXX/easybuild/build/ebtutorial/1.0.1/cpeCray-21.12" does not appear to contain CMakeLists.txt.
```

Wait, but there *is* a `CMakeLists.txt`, we can see it in the 
[unpacked sources](https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/eb-tutorial-1.0.1)!

Let's inspect the build directory:

```
$ ls /run/user/XXXXXXXXX/easybuild/build/ebtutorial/1.0.1/cpeCray-21.12
easybuild_obj
$ ls /run/user/XXXXXXXXX/easybuild/build/ebtutorial/1.0.1/cpeCray-21.12/easybuild_obj
$
```

There's nothing there at all! And that's not strange because we didn't actually
specify any sources in our easyconfig file...

The `sources` easyconfig parameter is commonly defined but it is *not* mandatory,
because some easyconfig files only specify bundles of software packages and hence only
serve to generate a module file.

So we need to specify one or more source files that should be used,
via the `sources` easyconfig parameter which specifies a *list* of
names of source files:

```python
sources = ['eb-tutorial-1.0.1.tar.gz']
```

We can avoid hardcoding the version number here by using a *template value*:

```python
sources = ['eb-tutorial-%(version)s.tar.gz']
```

And since this is a standard way of naming software files, there's
even a constant available that we can use:

```python
sources = [SOURCE_TAR_GZ]
```

That way, we only have the software version specified *once* in the easyconfig file,
via the `version` easyconfig parameter. That will come in useful later (see [Exercise 7.2](#exercises))...

If now we try installing the easyconfig file again, EasyBuild complains
that it can't find the specified source file anywhere:

```
Couldn't find file eb-tutorial-1.0.1.tar.gz anywhere, and downloading it didn't work either... 
Paths attempted (in order):...
```

To let EasyBuild automatically download the source file if it is not available yet,
we have to specify *where* it can be downloaded. This is done via `source_urls`:

```python
source_urls = ['https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/']
sources = [SOURCE_TAR_GZ]
```

### Required configure option

With `sources` and `source_urls` defined, we can try again. Yet again we see the configure step fail.
Is this a ruse to make you hate CMake with a passion? Maybe...

Here's what we find in the log file:

```
CMake Error at CMakeLists.txt:7 (message):
  EBTUTORIAL_MSG is not set!
```

Apparently the `eb-tutorial` software has a required configure option. It's almost as if that
was done on purpose, how silly!

Options to the configure command can be specified by the `configopts` easyconfig parameter.
To define the value of a CMake option, we need to use `-DNAME_OF_OPTION`, so:

```python
configopts = "-DEBTUTORIAL_MSG='Hello from the EasyBuild tutorial!' "
```

We need to be a little bit careful with quotes here. If we use outer double quotes,
we have to use single quotes to specify the actual value for the `EBTUTORIAL_MSG` configure option.
That works fine here, but that's not always the case!
In some cases we will have to use inner doubles quotes, for example to get environment variables
expanded when the configure command is run (see [Exercise 7.1](#exercises)).

### Sanity check

Hopefully that brings us closer to getting the installation to work...

```
$ eb eb-tutorial.eb
....
== sanity checking...
== ... (took 2 secs)
== FAILED: Installation ended unsuccessfully (build directory: /run/user/XXXXXXXXX/easybuild/build/ebtutorial/1.0.1/cpeCray-21.12):
build failed (first 300 chars): Sanity check failed: no (non-empty) directory found at 'lib' or 'lib64' in
/users/XXXXXXXX/EasyBuild/SW/LUMI-21.12/L/eb-tutorial/1.0.1-cpeCray-21.12 (took 7 secs)
```

It got all the way to the sanity check step, that's great!

The sanity check failed because no '`lib`' or `'lib64'` directory was found.
Indeed:

```
$ ls /users/XXXXXXXX/EasyBuild/SW/LUMI-21.12/L/eb-tutorial/1.0.1-cpeCray-21.12
bin
$ ls /users/XXXXXXXX/EasyBuild/SW/LUMI-21.12/L/eb-tutorial/1.0.1-cpeCray-21.12
eb-tutorial
```

There is only a binary named `eb-tutorial` in the `bin` subdirectory.
So we need to customize the standard sanity check:

```python
sanity_check_paths = {
    'files': ['bin/eb-tutorial'],
    'dirs': [],
}
```

Since we want to obtain a *working* installation, we might as well try to run this `eb-tutorial` command as well:

```python
sanity_check_commands = ['eb-tutorial']
```

Let us now retry, but use `--module-only` rather than redoing the whole installation.
`--module-only` still sanity checks the installation, so if it creates
a module, we know it will work as expected.
By enabling trace mode via `--trace` we can get some more information too:

```shell
$ eb eb-tutorial.eb --module-only --trace
...
== sanity checking...
  >> file 'bin/eb-tutorial' found: OK
  >> loading modules: eb-tutorial/1.0.1-cpeCray-21.12...
  >> running command 'eb-tutorial' ...
  >> result for command 'eb-tutorial': OK
...
== COMPLETED: Installation ended successfully (took 4 sec)
```

Yes, great success!

To convince yourself that the installation works as intended, try to load the `eb-tutorial` module and
run the `eb-tutorial` command yourself:

```
$ module load eb-tutorial
$ eb-tutorial
Hello from the EasyBuild tutorial!
```

### Complete easyconfig

Here is the complete easyconfig we puzzled together for this example:

```python
easyblock = 'CMakeMake'

name = 'eb-tutorial'
version = '1.0.1'

homepage = 'https://easybuilders.github.io/easybuild-tutorial'
description = "EasyBuild tutorial example"

toolchain = {'name': 'GCC', 'version': '10.2.0'}

source_urls = ['https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/']
sources = [SOURCE_TAR_GZ]
checksums = ['d6cec2ea298f4092cb1b880cb017220ab191561da941e9e480639cf3354b7ef9']

builddependencies = [('CMake', '3.18.4')]

configopts = "-DEBTUTORIAL_MSG='Hello from the EasyBuild tutorial!' "

sanity_check_paths = {
    'files': ['bin/eb-tutorial'],
    'dirs': [],
}

sanity_check_commands = ['eb-tutorial']

moduleclass = 'tools'
```

One additional easyconfig parameter we defined here is `checksums`,
which specifies SHA256 checksums for source (and patch) files,
so EasyBuild can verify them before performing an installation.

You can let EasyBuild determine *and* inject these SHA256 checksums
automatically via `eb --inject-checksums`:

```
$ eb eb-tutorial.eb --inject-checksums
...
== injecting sha256 checksums for sources & patches in example.eb...
== * eb-tutorial-1.0.1.tar.gz: d6cec2ea298f4092cb1b880cb017220ab191561da941e9e480639cf3354b7ef9
```

Finally, we should consider changing the name of the easyconfig that we just developed
to align with the EasyBuild conventions as otherwise it would not be found when used as
a dependency of another package. In this case, the name should be
`eb-tutorial-1.0.0-cpeCray-21.12.eb`. In fact, EasyBuild stored a processed version
of our easyconfig with that name in the repository:

```
$ ls $EASYBUILD_REPOSITORYPATH
eb-tutorial
$ ls $EASYBUILD_REPOSITORYPATH/eb-tutorial
eb-tutorial-1.0.1-cpeCray-21.12.eb
$ cat $EASYBUILD_REPOSITORYPATH/eb-tutorial/eb-tutorial-1.0.1-cpeCray-21.12.eb
...
```

Note that EasyBuild has added an additional parameter to the easyconfig file, `buildstats`,
with a lot of information about how easybuild was called and properties of the node on which
it was run. This file is still a valid easyconfig file though from which we can build the
program again.

Let's also inspect the installation directory when the whole build process has finished successfully.
This is very easy after loading the module, as EasyBuild-generated modules define a number of environment
variables for each module:

```
$ module load eb-tutorial
$ env | grep TUTORIAL
EBVERSIONEBMINTUTORIAL=1.0.1
EBDEVELEBMINTUTORIAL=/users/XXXXXXXX/EasyBuild/SW/LUMI-21.12/L/eb-tutorial/1.0.1-cpeCray-21.12/easybuild/eb-tutorial-1.0.1-cpeCray-21.12-easybuild-devel
EBROOTEBMINTUTORIAL=/users/XXXXXXXX/EasyBuild/SW/LUMI-21.12/L/eb-tutorial/1.0.1-cpeCray-21.12
```
The most interesting one of those variables is the `EBROOT` variable which points to the installation directory.
As variable names cannot contain minus signs, the minus in the module name is replaced with `MIN` in the name
of the variable (which is not the most consistent thing however as in the name of an easyblock it is replaced
with `minus`).

Let's have a look in that directory:

```
$ ls $EBROOTEBMINTUTORIAL
bin  easybuild
$ ls EBROOTEBMINTUTORIAL/easybuild
easybuild-eb-tutorial-1.0.1-20220401.184518.log
easybuild-eb-tutorial-1.0.1-20220401.184518_test_report.md
eb-tutorial-1.0.1-cpeCray-21.12-easybuild-devel
eb-tutorial-1.0.1-cpeCray-21.12.eb
reprod
$ ls EBROOTEBMINTUTORIAL/easybuild/reprod
easyblocks
eb-tutorial-1.0.1-cpeCray-21.12.eb
eb-tutorial-1.0.1-cpeCray-21.12.env
hooks
ls $EBROOTEBMINTUTORIAL/easybuild/reprod/easyblocks
cmakemake.py  configuremake.py
```

As you can see, EasyBuild has also created the `easybuild` subdirectory (and it actually told us about that
at the end of the installation) which contains a lot of information about the build, also to make it easier
to reproduce a build process afterwards.


---

## Exercises

---

***Exercise E.1**** - Making `eb-tutorial` a bit more personal*

Change the easyconfig file for `eb-tutorial` to make the message printed by the `eb-tutorial` command
a bit more personal: include the username of the account that was used to install the software in it
(using the `$USER` environment variable).

??? success "(click to show solution)"
    For this we need to change the value that is passed to the `EBTUTORIAL_MSG` configure option:
    ```python
    configopts = '-DEBTUTORIAL_MSG="Hello from the EasyBuild tutorial! I was installed by $USER." '
    ```
    Here we have to use inner double quotes, to ensure that the `$USER` environment variable is expanded
    by the shell when running the `cmake` configure command.

    When you run the `eb-tutorial` command yourself, you should get output like this (not a message that
    includes a literal '`$USER`' string):

    ```shell
    Hello from the EasyBuild tutorial! I was installed by example.
    ```

    To re-install the `example.eb` easyconfig, you will need to use `eb --rebuild` or `eb --force`.
    EasyBuild will also complain about modules that are loaded already if you tested the program above.
    A good way to get rid of all those modules on LUMI is to simply use `module purge`. You don't need
    to reload the software stack, but you will need to load `EasyBuild-user` again.

---

***Exercise E.2**** - Installing eb-tutorial version 1.1.0*

Install version 1.1.0 of the `eb-tutorial` example software,
which is a trivial version bump compared to version 1.0.1.

The sources are available via:

```
https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/eb-tutorial-1.1.0.tar.gz
```

You can leverage the `eb-tutorial` easyconfig file we have composed in the example above,
**but you should not make any manual changes to it!**

??? success "(click to show solution)"
    You can use the `--try-software-version` option for this:
    ```shell
    $ eb eb-tutorial.eb --try-software-version 1.1.0
    ...
    == building and installing eb-tutorial/1.1.0-cpeCray-21.12...
    ...
    == COMPLETED: Installation ended successfully (took 4 sec)
    ```
    To test:
    ```
    $ module load eb-tutorial/1.1.0-cpeCray-21.12
    $ eb-tutorial
    I have a message for you:
    Hello from the EasyBuild tutorial! I was installed by XXXXXXXX.
    ```
    (`eb-tutorial` version 1.0.1 doesn't print "`I have a message for you:`")

    EasyBuild has also created a new easyconfig for this configuration and stored
    in the repository and the `easybuild` subdirectory from the installation 
    directory. As on LUMI the repository is in the search path we can actually copy
    the file back to the current directory:
    ```
    eb --copy-ec eb-tutorial-1.1.0-cpeCray-21.12.    ```
    Some of the formatting is lost though and the checksum is still missing, so you may want
    to do some cleaning up.
    ```
    eb eb-tutorial-1.1.0-cpeCray-21.12.eb --inject-checksum
    ```


---

*[[next: Using external modules from the Cray PE]](2_03_external_modules.md)*
