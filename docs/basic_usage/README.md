# Basic usage

Now that we have installed and configured EasyBuild, we can start using it for what it is intended for:
getting scientific software installed without breaking a sweat or having to resist the urge to
shout out four-letter words.

We will look at the high-level workflow first, and then cover each aspect in more detail.

A couple of exercises are available at the end to help to make you more familiar with the
EasyBuild command line interface, so pay attention!

## Workflow

Installing software with EasyBuild is as easy (hah!) as specifying to the **`eb` command** what we
want to install, and then sitting back to enjoy a coffee or tea (or whatever beverage you prefer).

This is typically done by **specifying the name of one or more easyconfig files**, usually in combination
with the `--robot` option to enable dependency resolution.

It is recommended to first assess the current situation before letting EasyBuild install the software,
and to check which **dependencies** are already installed and which are still missing. In addition,
you may want to inspect the specifics of the **installation procedure** that will be performed by EasyBuild
and ensure that the configuration option are what you would expect, for example.

## Specifying easyconfigs

Letting EasyBuild know what should be installed can be done by specifying one or more easyconfig files,
which is also the most common way. Alternative methods like using the `--software-name` option won't be
covered in this tutorial, since they are not commonly used. We will briefly cover how to install
easyconfig files straight from a GitHub pull request later though
(see [here](../contributing#using-easyconfigs-from-a-pr)).

Arguments passed to the `eb` command, being anything that is *not* an option (which starts with `-` or `--`) or
is a value for a preceding option, are assumed to refer to easyconfig files. These could be:

* the *(absolute or relative) path* to an easyconfig file;
* the *name* of an easyconfig file;
* the path to a *directory* containing easyconfig files;

Specified paths to files must of course point to existing files; if not, EasyBuild will print an appropriate error message:

```shell
$ eb /tmp/does_not_exist.eb
ERROR: Can't find path /tmp/does_not_exist.eb
```

When only the *name* of an easyconfig file is specified, EasyBuild will automatically try and locate it.
First, it will consider the *current directory*. If no file with the specified name is found there
EasyBuild will search for the easyconfig file in the [robot search path](../configuration#robot-search-path).

If the path to an existing *directory* is provided, EasyBuild will walk through the entire directory
(including all subdirectories), retain all files of which the name ends with '`.eb`', and (try to) use these
as easyconfig files.


#### Example command

Suppose we have the current situation in our home directory:

* two (easyconfig) files named `example1` and `example2`;
* a subdirectory named `some_deps`, which has two easyconfig files `dep1.eb` and `dep2.eb`
  alongside a text file named `list.txt`;
* a subdirectory named `more_deps` located *in* the `some_deps` subdirectory,
  which contains another easyconfig file `dep3.eb`;

Or, visually represented:

```shell
example1
example2
some_deps/
|-- dep1.eb
|-- dep2.eb
|-- list.txt
|-- more_deps/
    |-- dep3.eb
```

In this context, we run the following EasyBuild command from our home directory:

```shell
eb bzip2-1.0.6.eb example1 $HOME/example2 deps
```

EasyBuild will interpret each of these arguments as follows:

* `bzip2-1.0.6.eb` is the name of an easyconfig file to locate via the robot search path
  (since it does not exist in the current directory);
* `example1` is the name of a file in the current directory, so it can be used directly;
* likewise, `$HOME/example2` specifies the path to an existing file, which can be used directly;
* `some_deps` is the relative path to an existing directory, so EasyBuild will scan it and find three
  easyconfig files: `some_deps/dep1.eb`, `some_deps/dep2.eb` and `some_deps/more_deps/dep3.eb`,
  ignoring the `list.txt` file since its name does not end with '`.eb`';

### Easyconfig filenames

Note that the `eb` command does not care how easyconfig files are named, at least to some extent: the '`.eb`'
file extension does matter w.r.t. easyconfig files being picked up in subdirectories.

File names for easyconfigs being mostly irrelevant is only correct with respect to the arguments passed to
the `eb` command however. As we will learn soon, the name of easyconfig files *does* matter when EasyBuild
needs to locate easyconfigs that can be used to resolve a specified dependency
(see [here](#enabling-dependency-resolution)).

This explains why easyconfig files usually adher to a very specific naming scheme,
corresponding to `<name>-<version>-<toolchain><versionsuffix>.eb`, where:

* `<name>` represents the software name;
* `<version>` represents the software version;
* `<toolchain>` represents the toolchain used in the easyconfig file, which consists of the toolchain name
  and version separated with a dash (`-`); this part (including the preceding `-`) is omitted when the
  [`system` toolchain](../introduction#system-toolchain) is used;
* `<versionsuffix>` represents the value of the `versionsuffix` easyconfig parameter,
  which is sometimes used to distinguish multiple variants of particular software installations
  (and is empty by default);


### Searching for easyconfigs

You will frequently need to determine the exact name of an easyconfig file you want to install,
or just check which easyconfigs are available for a given software package, 
which you can do by searching for easyconfigs using **`eb --search`** or **`eb -S`**.

By default all directories listed in the [robot search path](../configuration#robot-search-path) will be
searched. If you want to search in additional directories without changing the robot search path
you can use the `search-paths` configuration setting, or you can change the robot search path via either
the `--robot` or `--robot-paths` option.

Both the `--search` and `-S` options trigger the same search operation, but yield different output:
`eb --search` will print the full path to each easyconfig file that matches the specified search pattern,
while `eb -S` produces a more concise output.

For example, let's check which easyconfig files are available for TensorFlow 2.2.0:

```shell
$ eb --search tensorflow-2.2.0
 * /easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs/t/TensorFlow/TensorFlow-2.2.0-foss-2019b-Python-3.7.4.eb
 * /easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs/t/TensorFlow/TensorFlow-2.2.0-fosscuda-2019b-Python-3.7.4.eb
```

This output is a bit more condensed when using `eb -S`:

```
$ eb -S tensorflow-2.2.0
CFGS1=/easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs/t/TensorFlow
 * $CFGS1/TensorFlow-2.2.0-foss-2019b-Python-3.7.4.eb
 * $CFGS1/TensorFlow-2.2.0-fosscuda-2019b-Python-3.7.4.eb
```

Note that the search is performed *case-insenstive*.

The search pattern can include wildcards like `.*` or character groups like `[0-9]`,
but you need to be careful that `bash` does not expand these before the `eb` command is started,
by wrapping the search pattern in single quotes (`'...'`).

For example, to check which easyconfigs are available to install OpenFOAM with the `foss/2019b` toolchain:

```
$ eb -S 'openfoam-[0-9].*foss-2019b'
CFGS1=/easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs/o/OpenFOAM
 * $CFGS1/OpenFOAM-6-foss-2019b.eb
 * $CFGS1/OpenFOAM-7-foss-2019b.eb
```

#### Search index

When searching for easyconfig files, you may see a message like this pop up:

```
== found valid index for <path>, so using it...
```

This indicates that a **search index** was used for this particular directory, which signficantly speeds
up the search procedure, especially when the easyconfig files are located on a shared filesystem where metadata
operations involving lots of small files are rather slow.

For the easyconfig files included with an EasyBuild release, a search index is readily provided.
For other directories, you can create a search index using `eb --create-index <path>`.

[See the EasyBuild documentation for more information](https://easybuild.readthedocs.io/en/latest/Easyconfigs_index.html).

## Inspecting easyconfigs

Once you have determined the name of the easyconfig file that corresponds to the software you want to install,
you may want to take a closer look at its contents before employing it.

Since easyconfig files are simple text files (in Python syntax), you could use the ubiquitous `cat` command
or your favorite text editor (`vim`, what else). To avoid that you need to copy-paste the full path to
the easyconfig file, you can also use **`eb --show-ec`**.

For example, let's inspect the contents of the `bzip2-1.0.6.eb` easyconfig file:

```shell
$ eb --show-ec bzip2-1.0.6.eb
== temporary log file in case of crash /tmp/eb-jnpzclhl/easybuild-e37cbrj1.log
== Contents of /easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs/b/bzip2/bzip2-1.0.6.eb:
name = 'bzip2'
version = '1.0.6'

homepage = 'https://sourceware.org/bzip2'
description = """bzip2 is a freely available, patent free, high-quality data compressor. It typically
compresses files to within 10% to 15% of the best available techniques (the PPM family of statistical
compressors), whilst being around twice as fast at compression and six times faster at decompression."""

toolchain = SYSTEM
toolchainopts = {'pic': True}

source_urls = ['https://sourceware.org/pub/bzip2/']
sources = [SOURCE_TAR_GZ]
patches = ['bzip2-%(version)s-pkgconfig.patch']
checksums = [
    'a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd',  # bzip2-1.0.6.tar.gz
    '5a823e820b332eca3684416894f58edc125ac3dace9f46e62f98e45362aa8a6d',  # bzip2-1.0.6-pkgconfig.patch
]

buildopts = "CC=gcc CFLAGS='-Wall -Winline -O3 -fPIC -g $(BIGFILES)'"

# building of shared libraries doesn't work on OS X (where 'gcc' is actually Clang...)
with_shared_libs = OS_TYPE == 'Linux'

moduleclass = 'tools'

== Temporary log file(s) /tmp/eb-jnpzclhl/easybuild-e37cbrj1.log* have been removed.
== Temporary directory /tmp/eb-jnpzclhl has been removed.
```

## Checking dependencies

!!! note
    In some of the examples below, we assume that some software is already installed with EasyBuild.

    If you are following hands-on in a prepared environment, make sure these installations are visible
    in the output of "`module avail`".

    **When using the [prepared container image](../practical_information/#prepared-container-image),
    run this command to make the already installed software stack available:**
    ```shell
    module use /easybuild/modules/all
    ```

Before kicking off an installation, it is good practice to check which of the required dependencies
are already installed, and which ones are still missing.

This can be helpful to ensure that your EasyBuild configuration is set up correctly,
and to prevent from accidentally installing an entirely new software stack from scratch
in an intended location (like `$HOME/.local/easybuild`, which is the
[default installation path](../configuration/#install-path)).

### Dry run

To get a complete overview of all required dependencies, and see which ones are already installed
and which ones aren't yet, you can use `eb --dry-run`.

Since `--dry-run` produces rather verbose output including the full path to each easyconfig file,
there is a more concise equivalent available as well: `eb --dry-run-short`, which is equivalent with `eb -D`.

For example, to check which of the dependencies that are required for `SAMtools-1.10-GCC-9.3.0.eb` are already installed:

```shell
$ eb SAMtools-1.10-GCC-9.3.0.eb -D
== temporary log file in case of crash /tmp/eb-x4qofiph/easybuild-ehhi9fb1.log
== found valid index for /easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs, so using it...
Dry run: printing build status of easyconfigs and dependencies
CFGS=/easybuild/software/EasyBuild/4.2.1/easybuild/easyconfigs
 ...
 * [x] $CFGS/b/bzip2/bzip2-1.0.8-GCCcore-9.3.0.eb (module: bzip2/1.0.8-GCCcore-9.3.0)
 * [x] $CFGS/x/XZ/XZ-5.2.5-GCCcore-9.3.0.eb (module: XZ/5.2.5-GCCcore-9.3.0)
 * [x] $CFGS/c/cURL/cURL-7.69.1-GCCcore-9.3.0.eb (module: cURL/7.69.1-GCCcore-9.3.0)
 * [x] $CFGS/g/GCC/GCC-9.3.0.eb (module: GCC/9.3.0)
 * [x] $CFGS/n/ncurses/ncurses-6.2-GCCcore-9.3.0.eb (module: ncurses/6.2-GCCcore-9.3.0)
 * [ ] $CFGS/s/SAMtools/SAMtools-1.10-GCC-9.3.0.eb (module: SAMtools/1.10-GCC-9.3.0)
```

(We've trimmed the output a bit here, for the sake of brevity.)

This output tells us that all dependencies required by `SAMtools-1.10-GCC-9.3.0.eb` are already installed,
since they are all marked with `[x]`, whereas the easyconfig for `SAMtools` itself is not installed yet,
as indicated by the `[ ]`.

### Missing dependencies

If you are only interested in which dependencies are still *missing*,
you can consult the output of **`eb --missing`**, or the equivalent **`eb -M`**.

For example, let's see which dependencies are missing in order to get `h5py` version 2.10.0
using the `2020a` version of the `foss` toolchain installed:

```shell
$ eb h5py-2.10.0-foss-2020a-Python-3.8.2.eb -M

2 out of 54 required modules missing:

* pkgconfig/1.5.1-GCCcore-9.3.0-Python-3.8.2 (pkgconfig-1.5.1-GCCcore-9.3.0-Python-3.8.2.eb)
* h5py/2.10.0-foss-2020a-Python-3.8.2 (h5py-2.10.0-foss-2020a-Python-3.8.2.eb)
```

That should be pretty self-explanatory: out of the 54 required dependencies (which includes the `foss` toolchain
and everything needed to install it), only 2 dependencies are missing. Great!

## Inspecting install procedures

Finally, before actually installing something you may want to assess *how* exactly EasyBuild is going
to install the software.

Perhaps you don't trust EasyBuild yet (you will eventually though, hopefully),
or maybe you just want to double check that you have made the right choice before going through with
the actual installation.

Using **`eb --extended-dry-run`**, or just **`eb -x`** for short,
you can **get a detailed overview of the installation procedure that would be performed by EasyBuild**,
**in a matter of seconds**.

By means of example, let's inspect some parts of the installation procedure for `Boost-1.72.0-gompi-2020a.eb`:

```shell
$ eb Boost-1.72.0-gompi-2020a.eb -x
...

preparing... [DRY RUN]

[prepare_step method]
Defining build environment, based on toolchain (options) and specified dependencies...

Loading toolchain module...

module load gompi/2020a

Loading modules for dependencies...

module load bzip2/1.0.8-GCCcore-9.3.0
module load zlib/1.2.11-GCCcore-9.3.0
module load XZ/5.2.5-GCCcore-9.3.0

...

Defining build environment...

  ...
  export CXX='mpicxx'
  export CXXFLAGS='-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC'
  ...

configuring... [DRY RUN]

[configure_step method]
  running command "./bootstrap.sh --with-toolset=gcc --prefix=/dev/shm/example/Boost/1.72.0/gompi-2020a/obj --without-libraries=python"
  (in /tmp/kehoste/fakehome/.local/easybuild/build/Boost/1.72.0/gompi-2020a/Boost-1.72.0)
file written: user-config.jam

...

[sanity_check_step method]
Sanity check paths - file ['files']
  * lib/libboost_mpi.so
  * lib/libboost_system.so
Sanity check paths - (non-empty) directory ['dirs']
  * include/boost
Sanity check commands
  (none)

...
```

We've obviously trimmed the generated output a bit, but it should be sufficient.

An overview of the installation procedure is shown, following the installation steps as they would be
performed by EasyBuild. The output above shows:

* how the build environment will be set up during the `prepare` step, by loading the module for both the
  toolchains and the dependencies, and defining a set of environment variables like `$CXX`, `$CXXFLAGS`, etc.
* which command will be executed during the configuration step and in which directory,
  and that a file named `user-config.jam` will be created as well;
* the list of files and directories that will be checked during the sanity check step;

If you were concerned about EasyBuild being too much of a black box, that is hopefully resolved now.

!!! note
    It is important to highlight here that the reported installation procedure *may* not be 100% correct,
    since the [easyblock](../introduction/#easyblocks) can change its mind based on the output of shell commands
    that were executed, or based on the contents of a file that was generated during the installation.
    Since all "actions" that would be performed during the installation are actually skipped when using `eb -x`,
    the reported installation procedure could be partially incorrect.

    In addition, the easyblock may trip over the fact that the installation procedure is not actually being
    executed, which sometimes leads to an unexpected error. These situations are handled gracefully by `eb -x`
    though, which will report any errors that occured and then continue anyway with inspecting the remainder of the
    installation procedure. Although this obviously limits the value of the generated output,
    it doesn't make it completely useless.

## Installing software

### Enabling dependency resolution

### Trace output

`--trace`

### Example installation

## Using installed software

## Stacking software

## Hands-on exercises

***Guidelines***

Do yourself a favor: don't peek at the solution until you have made an attempt to solve the exercise yourself!

Please do not spoil solutions to others before they have been discussed by the tutorial organisers.

---

***Exercise 4.0**** - Making installed software available*

Before working on the exercises for this part of the tutorial,
make sure that the software that is already installed in the prepared environment is available.

For the [`easybuilders/tutorial` container image](../practical_information/#prepared-container-image)), we have installed a small software stack with the `foss/2020a` toolchain
in `/easybuild/`.

**Tip:** use a "`module use`" command, and verify with "`module avail`" that a bunch of software modules
are available for loading.

??? success "(click to show solution)"

    Use the following command to make the modules for the software available that is pre-installed
    in the prepared environment:
    ```shell
    module use /easybuild/modules/all
    ```

    If software is installed in a different location than `/easybuild/` in your environment,
    you should adjust the command accordingly.
    

---

***Exercise 4.1**** - Searching easyconfigs*

See if EasyBuild provides any easyconfig files for installing TensorFlow version 2.2.0.

??? success "(click to show solution)"
    ```shell
    eb --search TensorFlow-2.2.0
    ```

---

***Exercise 4.2****- Checking dependencies*

Check which dependencies are missing to install PETSc version 3.12.4 with the `2020a` version of the `foss` toolchain.

??? success "(click to show solution)"
    ```shell
    eb --search 'PETSc-3.12.4.*foss-2020a'
    ```
    ```shell
    eb PETSc-3.12.4-foss-2020a-Python-3.8.2.eb --missing
    ```

---

***Exercise 4.3****- Performing a dry run*

Inspect the installation procedure for `GSL-2.6-GCC-9.3.0.eb` by performing a dry run.

Which binaries will EasyBuild check for to sanity check the installation?

??? success "(click to show solution)"
    ```shell
    eb -x GSL-2.6-GCC-9.3.0.eb
    ```

    Binaries: `gsl-config`, `gsl-histogram`, `gsl-randist`.

---

***Exercise 4.4****- Installing software*

Install the `h5py` Python package and all missing dependencies for Python 3.8.2,
into `/tmp/$USER/easybuild` and leveraging already install software from `/easybuild`.

Enable trace output so you can see which parts of the installation take a while.

??? success "(click to show solution)"
    ```shell
    eb --search 'h5py.*Python-3.8.2'
    ```
    ```shell
    module use /easybuild/modules/all
    ```
    ```shell
    eb h5py-2.10.0-foss-2020a-Python-3.8.2.eb --missing
    ```
    ```shell
    eb h5py-2.10.0-foss-2020a-Python-3.8.2.eb --robot --installpath /tmp/$USER/easybuild
    ```

---

***Exercise 4.5****- Using installed software*

Using the `h5py` installation from the previous exercise to create an empty HDF5 file,
using the following Python statements:

```python
import h5py
f = h5py.File("mytestfile.hdf5", "w")
f.close()
```

Check the resulting file using the `h5stat` command.

??? success "(click to show solution)"
    ```shell
    module use /tmp/$USER/easybuild/modules/all
    ```
    ```shell
    module avail h5py
    ```
    ```shell
    module load h5py/2.10.0-foss-2020a-Python-3.8.2
    ```
    ```shell
    python -c 'import h5py; f = h5py.File("empty.hdf5", "w"); f.close()'
    ```
    ```shell
    h5stat empty.hdf5
    ```

---
