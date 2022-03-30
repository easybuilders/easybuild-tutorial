# Creating easyconfig files

*[[back: Troubleshooting]](2_02_troubleshooting.md)*

---

We already know how to install easyconfig files that are included with EasyBuild,
but what about installing software for which no easyconfig is available yet?

To do this we will need to **create additional easyconfig files**,
since every software installation performed by EasyBuild is done based on an easyconfig file.

In this part of the tutorial we will look at the guts of easyconfig files and even create some ourselves!

## Easyconfigs vs easyblocks

Before we dive into writing [easyconfig files](../introduction/#easyconfig-files),
let us take a brief look at how they relate to [easyblocks](../introduction/#easyblocks).

As we discussed [earlier](../introduction/#terminology), an easyconfig file (`*.eb`) is required
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
that are used for the installation, etc.

In a nutshell, custom software-specific easyblocks are "do once and forget": they are central solution to peculiarities in the installation procedure of a particular software package.

Reasons to consider implementing a software-specific easyblock rather than using a generic easyblock include:

* 'critical' values for easyconfig parameters required to make installation succeed;
* toolchain-specific aspects of the build and installation procedure (e.g., configure options);
* interactive commands that need to be run;
* custom (configure) options for dependencies;
* having to create or adjust specific (configuration) files;
* 'hackish' usage of a generic easyblock;
* complex or very non-standard installation procedure;

Implementing easyblocks is out of scope for this basic tutorial, for more information please consult
the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Implementing-easyblocks.html).

## Writing easyconfig files

Writing an easyconfig file boils down to defining a set of easyconfig parameters in a text file,
which we give a '`.eb`' extension by convention. The name of an easyconfig file doesn't matter
when using it directly to install software, but it does matter when EasyBuild needs to find it
to resolve a dependency for example (as we [discussed earlier](../basic_usage/#easyconfig-filenames)).

The syntax for easyconfig files is *Python syntax*: you are basically defining a bunch of Python variables
that correspond to easyconfig parameters.

The order in which the easyconfig parameters are defined doesn't matter, but we generally try to strick to a particular
order which roughly corresponds to the order in which the easyconfig parameters are used during the installation.
That is mostly helpful for humans staring at easyconfig files or comparing them.

### Mandatory parameters

A limited number of easyconfig parameters are *mandatory*, they must be defined in every easyconfig file:

* `name`: the name of the software to install;
* `version`: the version of the software to install;
* `homepage`: a URL to the website of the software;
* `description`: a short description of the software;
* `toolchain`: the compiler toolchain to use for the installation;

**`name`, `version`**

It should be no surprise that specifying the name and version of the software you want to install is mandatory.
This information may influence the value of several other easyconfig parameters (like the name of the source file), and is also used to the determine the name of the module file to install.

```python
name = 'example'
version = '1.0'
```

**`homepage`, `description`**

The homepage and description are included in the generated module file for the installation.
That way the "`module show`" command provides some useful high-level information about the installation.

```python
homepage = 'https://example.org'
description = "This is just an example."
```

Usually it does not matter whether you use single or double quotes to specify string values,
but you will often see that single quotes are used for values that don't have spaces (words)
and double quotes for values that do have spaces (sentences). There is no technical reason for
this, it just feels more natural to some people. There are cases where it is important to use
the right type of quotes however, we will get back to that later (keep it in mind for the exercises!).

For multi-line descriptions, you will need to use "triple quoting" (which is standard Python syntax):

```python
description = """This is an example
 of a multi-line description.
 It is spread across multiple lines."""
```

**`toolchain`**

EasyBuild also requires that the [compiler toolchain](../introduction/#toolchains) is specified, via the `toolchain`
easyconfig parameter.

This can either be the [`system` toolchain](../introduction/#system-toolchain), for which a constant named `SYSTEM` is available:

```python
toolchain = SYSTEM
```

Usually we specify a 'proper' toolchain like the compiler-only toolchain GCC 10.2.0 which we used before,
or the full toolchain `foss` 2020b. The name and version of the toolchain can be specified using a small Python dictionary,
for example:

```python
toolchain = {'name': 'GCC', 'version': '10.2.0'}
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
* Source files can also be specified in ways other than just using a filename, see the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html#common-easyconfig-param-sources-alt) for more information.
* Specified checksums are usually SHA256 checksum values, but [other types are also supported](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html?highlight=checksums#checksums).


#### Easyblock

The easyblock that should be used for the installation can be specified via the `easyblock` easyconfig parameter.

This is not mandatory however, because by default EasyBuild will determine the easyblock to use based on the
name of the software. If '`example`' is specified as software name, EasyBuild will try to locate a
software-specific easyblock named `EB_example` (in a Python module named `example.py`). Software-specific
easyblocks follow the convention that the class name starts with `'EB_`', followed by the software name
(where some characters are replaced, like '`-`' with '`_minus_`').

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

You will often need to list one or more [dependencies](../introduction/#dependencies) that are required
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
the build.

Here is a simple example of specifying dependencies:

```python
builddependencies = [('CMake', '3.18.4')]

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
specification, to avoid hardcoding the Python version in different places.

See also the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Writing_easyconfig_files.html#dependencies) for additional options on specifying dependencies.


#### Version suffix

In some cases you may want to build a particular software package in different configurations, or include a label in the module name to highlight a particular aspect
of the installation.

The `versionsuffix` easyconfig parameter can be used for this purpose. The name of this parameter implies that this label will be added after the
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
The `versionsuffix` label is helpful to inform the user that a particular Python version is required by the installation.

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

This is done to categorize software, and it is used to group the generated module files into smaller sets ([remember what we saw when installing software earlier](../basic_usage/#using-installed-software)).

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
eb example-1.2.3-foss-2020b.eb --try-toolchain intel,2020b
```

It is important to keep in mind the *"try"* aspect here: while easyconfigs that
are generated by EasyBuild via a `--try-*` option often do work fine, there is
no strong guarantee they will. Newer software versions may come with changes to
the installation procedure, additional dependencies that are required, etc.
Using a different compiler toolchain may be as simple as just switching one for
another, but it may require additional changes to be made to configure options, for example.

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

Make sure EasyBuild is properly configured before you start:

```shell
export EASYBUILD_PREFIX=$HOME/easybuild
export EASYBUILD_BUILDPATH=/tmp/$USER
```

and that the installed software in `/easybuild` is available:

```shell
module use /easybuild/modules/all
```

### Mandatory parameters

Let's start by getting the mandatory easyconfig parameters defined in the easyconfig file:

```python
name = 'eb-tutorial'
version = '1.0.1'

homepage = 'https://easybuilders.github.io/easybuild-tutorial'
description = "EasyBuild tutorial example"
```

If we try using this (very) minimal easyconfig file, EasyBuild will inform us that we failed to specify one of the mandatory easyconfig parameters: `toolchain`:

```
$ eb example.eb
== Temporary log file in case of crash /tmp/eb-90j723rl/easybuild-q21plqvx.log
== found valid index for /easybuild/software/EasyBuild/4.3.3/easybuild/easyconfigs, so using it...
ERROR: Failed to process easyconfig /home/example/example.eb: mandatory parameters not provided in pyheader: toolchain
```

We will use `GCC/10.2.0` as toolchain, since we know it is already installed in `/easybuild` in the prepared environment, so we also define the `toolchain` easyconfig parameter:

```python
toolchain = {'name': 'GCC', 'version': '10.2.0'}
```

In addition, we'll also specify the `moduleclass`.
This is not required, but it is usually set to a sensible value:

```python
moduleclass = 'tools'
```

The default value is '`base`', at least '`tools`' has *some* meaning.

### Easyblock

Let us see what happens if we take our current easyconfig file for a spin:

```shell
$ eb example.eb
== temporary log file in case of crash /tmp/eb-8_vxjfn7/easybuild-k3aaoan2.log
ERROR: Failed to process easyconfig /home/example/example.eb:
No software-specific easyblock 'EB_eb_minus_tutorial' found for eb-tutorial
```

That didn't get us very far...

The error shows that there is no software-specific easyblock available for installing the software with the name '`eb-tutorial`'.
Does that mean we have to implement an easyblock?

In this simple case it doesn't, since we can leverage one of the available *generic easyblocks*.
But, which one?

Build instructions are usually included in a `README` file, or in the documentation.
In this case, there's indeed a minimal [`README`
file](https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/eb-tutorial-1.0.1/README) available,
which tells us that we should use the `cmake` command to configure the installation, followed by `make` and `make install`.

[We briefly discussed](#easyblock) a generic easyblock that does exactly this: `CMakeMake`.

```python
easyblock = 'CMakeMake'
```

The "`easyblock =`" line is usually at the top of the easyconfig file, but strictly speaking
the order of the parameter definitions doesn't matter (unless one is defined in terms of another one).

### CMake build dependency

Does using the `CMakeMake` generic easyblock help at all?

```
$ eb example.eb
== temporary log file in case of crash /tmp/eb-yutbor1p/easybuild-4jc9v1u9.log
== found valid index for /easybuild/software/EasyBuild/4.3.3/easybuild/easyconfigs, so using it...
== processing EasyBuild easyconfig /home/example/example.eb
== building and installing eb-tutorial/1.0.1-GCC-10.2.0...
== fetching files...
== creating build dir, resetting environment...
== unpacking...
== patching...
== preparing...
== configuring...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/easybuild/ebtutorial/1.0.1/GCC-10.2.0):
build failed (first 300 chars): cmd " cmake -DCMAKE_INSTALL_PREFIX=/home/example/easybuild/software/eb-tutorial/1.0.1-GCC-10.2.0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER='gcc' -DCMAKE_C_FLAGS='-O2 -ftree-vectorize -march=native -fno-math-errno' -DCMAKE_CXX_COMPILER='g++' -DCMAKE_CXX_FLAGS='-O2 -ftree-vectorize -march=native  (took 0 sec)
```

It did help: EasyBuild made an attempt to configure the build using the `cmake` command, but that failed almost
instantly. We need to dive into the log file to see the actual reason. By starting at the end of the log file and
scrolling up, you should be able to locate the following error message:

```
/bin/bash: cmake: command not found
```

Ah, that explains it, `cmake` isn't even installed on this system. Or is it?

```shell
$ module avail CMake

--------------------------- /easybuild/modules/all ----------------------------
   CMake/3.18.4-GCCcore-10.2.0
```

Since a module is available for `CMake` that is compatible with the toolchain we are using (GCC 10.2.0),
we can use it as a dependency for the installation.
It is only needed for building the software, not for running it, so it's only a *build* dependency:

```python
builddependencies = [('CMake', '3.18.4')]
```

There is usually no need to specify toolchain for (build) dependencies, EasyBuild will automatically consider
[subtoolchains](../terminology/#toolchains) compatible with the specified toolchain to locate module for the dependencies.

You can verify this via `eb -D` (equivalent with `eb --dry-run`):

```
$ eb example.eb -D
 ...
 * [x] /easybuild/software/EasyBuild/4.3.3/easybuild/easyconfigs/g/GCC/GCC-10.2.0.eb (module: GCC/10.2.0)
 * [x] /easybuild/software/EasyBuild/4.3.3/easybuild/easyconfigs/c/CMake/CMake-3.18.4-GCCcore-10.2.0.eb (module: CMake/3.18.4-GCCcore-10.2.0)
 * [ ] /home/example/example.eb (module: eb-tutorial/1.0.1-GCC-10.2.0)
```

### Sources

If you try again after adding `CMake` as a build dependency, you will see the installation fail again in the
configuration step. Inspecting the log file reveals this:

```
CMake Error: The source directory "/tmp/example/ebtutorial/1.0.1/GCC-10.2.0" does not appear to contain CMakeLists.txt.
```

Wait, but there *is* a `CMakeLists.txt`, we can see it in the [unpacked sources](https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/eb-tutorial-1.0.1)!

Let's inspect the build directory:

```
$ ls /tmp/$USER/ebtutorial/1.0.1/GCC-10.2.0
easybuild_obj
$ ls /tmp/$USER/ebtutorial/1.0.1/GCC-10.2.0/easybuild_obj
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
$ eb example.eb
....
== sanity checking...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/easybuild/ebtutorial/1.0.1/GCC-10.2.0): build failed (first 300 chars):
Sanity check failed: no (non-empty) directory found at 'lib' or 'lib64' in /home/easybuild/easybuild/software/eb-tutorial/1.0.1-GCC-10.2.0 (took 2 sec)
```

It got all the way to the sanity check step, that's great!

The sanity check failed because no '`lib`' or `'lib64'` directory was found.
Indeed:

```
$ ls $HOME/easybuild/software/eb-tutorial/1.0.1-GCC-10.2.0
bin
$ ls $HOME/easybuild/software/eb-tutorial/1.0.1-GCC-10.2.0/bin
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
$ eb example.eb --module-only --trace
...
== sanity checking...
  >> file 'bin/eb-tutorial' found: OK
  >> running command 'eb-tutorial' ...
  >> result for command 'eb-tutorial': OK
...
== COMPLETED: Installation ended successfully (took 4 sec)
```

Yes, great success!

To convince yourself that the installation works as intended, try to load the `eb-tutorial` module and
run the `eb-tutorial` command yourself:

```
$ module use $HOME/easybuild/modules/all
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
$ eb example.eb --inject-checksums
...
== injecting sha256 checksums for sources & patches in example.eb...
== * eb-tutorial-1.0.1.tar.gz: d6cec2ea298f4092cb1b880cb017220ab191561da941e9e480639cf3354b7ef9
```

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
    $ eb example.eb --try-software-version 1.1.0
    ...
    == building and installing eb-tutorial/1.1.0-GCC-10.2.0...
    ...
    == COMPLETED: Installation ended successfully (took 4 sec)
    ```
    To test:
    ```
    $ module use $HOME/easybuild/modules/all
    $ module load eb-tutorial/1.1.0-GCC-10.2.0
    $ eb-tutorial
    I have a message for you:
    Hello from the EasyBuild tutorial!
    ```
    (`eb-tutorial` version 1.0.1 doesn't print "`I have a message for you:`")

---

***Exercise E.3**** - Installing py-eb-tutorial 1.0.0*

Try composing an easyconfig file for the `py-eb-tutorial` example software, which is a tiny Python package.
The source tarball can be downloaded from this link: [py-eb-tutorial-1.0.0.tar.gz](https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/py-eb-tutorial-1.0.0.tar.gz).

A couple of tips:

* There is a [generic easyblock](#easyblock) available for installing Python packages, which will come in useful here.

* By default EasyBuild performs an `import` check when install Python packages, using a Python module name that is derived from the software name by default, which will be incorrect in this case. You can specify the correct name to use in the import check by specifying it via the `options`
easyconfig parameter in your easyconfig file:
  ```python
  options = {'modulename': 'example'}
  ```
  (you will need to change '`example`' here, of course)

* Leverage the software that is already pre-installed in `/easybuild` in the prepared environment.
  Remember that some already installed modules may be a *bundle* of a couple of other software packages.

Please also take this into account:

* Unfortunately this software doesn't come with documentation. That is done to make it an example that
  is representative for software that you may run into in the wild (it's *not* because
  we were lazy when preparing the exercises, really!).
  You can inspect the sources of this software [here](https://github.com/easybuilders/easybuild-tutorial/tree/main/docs/files/py-eb-tutorial-1.0.0). Definitely take a look at the `setup.py` file, it includes some clues
  about the requirements to get this software installed.

* Make sure the installation actually *works*, by checking that the `py-eb-tutorial` command runs correctly.
  Maybe you will need to make sure other required software is available as well, for it to work correctly...


??? success "(click to show solution)"

    Here is a complete working easyconfig file for `py-eb-tutorial`:
    ```python

    easyblock = 'PythonPackage'

    name = 'py-eb-tutorial'
    version = '1.0.0'
    versionsuffix = '-Python-%(pyver)s'

    homepage = 'https://easybuilders.github.io/easybuild-tutorial'
    description = "EasyBuild tutorial Python example"

    source_urls = ['https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/']
    sources = [SOURCE_TAR_GZ]
    checksums = ['fcf73a9efc65527a210b993e8889d41ebf05977eef1f6a65ebac3188152cd496']

    toolchain = {'name': 'foss', 'version': '2020b'}

    dependencies = [
        ('Python', '3.8.6'),
        ('SciPy-bundle', '2020.11'),
        ('eb-tutorial', '1.0.1'),
    ]

    use_pip = True

    options = {'modulename': 'eb_tutorial'}

    sanity_check_paths = {
        'files': ['bin/py-eb-tutorial'],
        'dirs': ['lib/python%(pyshortver)s/site-packages'],
    }

    sanity_check_commands = ["py-eb-tutorial"]

    moduleclass = 'tools'
    ```

    Some remarks:

    * We used the `PythonPackage` generic easyblock. There is also a `PythonBundle` easyblock for installing
      bundles of Python packages, which is used for `SciPy-bundle` for example. But we don't need that here,
      since we are only dealing with a single Python package.

    * The `versionsuffix` is not strictly needed, but it's common to tag Python packages with the Python version
      for which they were installed.
    * The SHA256 checksum for the source tarball was added automatically via `eb py-eb-tutorial.eb --inject-checksums`.

    * `py-eb-tutorial` only wants to be installed with `pip install`, so we had to set `use_pip = True`.
      You can consult the custom easyconfig parameters supported by the `PythonPackage` easyblock via
      "`eb -a -e PythonPackage`", see the `EASYBLOCK-SPECIFIC` part of the output.
      Even when the default installation mechanism used by `PythonPackage`
      (which consists of running `python setup.py install`) works fine,
      it is recommended to instruct EasyBuild to use `pip install` instead.

    * By default EasyBuild will try to import `py_eb_tutorial`, while the actual name of the Python package
      provided by `py-eb-tutorial` is just `eb_tutorial`. We fixed this by specifying the correct Python module name to
      use via `options`.

    * Strictly speaking we don't need to specify a custom `sanity_check_paths`, since the default used
      by Python package is already pretty decent (it will check for a non-empty `lib/python3.8/site-packages`
      directory in the installation). We also want to make sure the `py-eb-tutorial` command is available in
      the `bin` subdirectory however. Hardcoding to `python3.8` can be avoided using the `%(pyshortver)s`
      template value.

    * A good way to check whether the `py-eb-tutorial` command works correctly is by running it as a sanity check
      command. If the `eb-tutorial` command is not available the `py-eb-tutorial` command will fail,
      since it basically just runs the `eb-tutorial` command. So we need to include `eb-tutorial` as a (runtime)
      dependency in the `py-eb-tutorial` easyconfig file.

*[[next: Implementing easyblocks]](2_03_implementing_easyblocks.md)*
