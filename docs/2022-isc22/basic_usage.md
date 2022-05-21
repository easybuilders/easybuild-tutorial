# Basic usage of Easybuild

Now that we have [installed](installation.md) and [configured](configuration.md) EasyBuild,
we can start using it for what it is intended for: getting scientific software installed
without breaking a sweat, or having to resist the urge to shout out four-letter words.

We will look at the high-level workflow first, and then cover each aspect in more detail.

A couple of exercises are available at the end to help to make you more familiar with the
EasyBuild command line interface, so pay attention!

---

## Overall workflow

Installing software with EasyBuild is as easy as specifying to the **`eb` command** what we
want to install, and then sitting back to enjoy a coffee or tea (or whatever beverage you prefer).

This is typically done by **specifying the name of one or more easyconfig files**, often combined
with the `--robot` option to let EasyBuild also install missing dependencies.
Alternatively one can specify the name of an easystack file that specifies a collection of
software to install, but this feature is currently still marked as * experimental* meaning
that it may fail or that may change in incompatible ways in future versions of EasyBuild.

It is recommended to first assess the current situation before letting EasyBuild install the software,
and to check which **dependencies** are already installed and which are still missing. In addition,
you may want to inspect the specifics of the **installation procedure** that will be performed by EasyBuild,
and ensure that the active EasyBuild configuration is what it should be.

---

## Specifying easyconfigs

Letting EasyBuild know what should be installed can be done by specifying one or more easyconfig files,
which is also the most common way. Alternative methods like using the `--software-name` option won't be
covered in this tutorial, since they are not commonly used.

Arguments passed to the `eb` command, being anything that is *not* an option (which starts with `-` or `--`) or
is a value for a preceding configuration option, are assumed to refer to easyconfig files (with some exceptions).
These could be:

* the *(absolute or relative) path* to an easyconfig file;
* the *name* of an easyconfig file;
* the path to a *directory* containing easyconfig files;
* an easystack file to specify a whole stack of software to install at once (via `eb --easystack`);

Specified paths to files must of course point to existing files; if not, EasyBuild will print an appropriate error message:

```shell
$ eb /tmp/does_not_exist.eb
ERROR: Can't find path /tmp/does_not_exist.eb
```

When only the *name* of an easyconfig file is specified, EasyBuild will automatically try and locate it.
First, it will consider the *current directory*. If no file with the specified name is found there,
EasyBuild will search for the easyconfig file in the [robot search path](../configuration/#robot-search-path).

If the path to an existing *directory* is provided, EasyBuild will walk through the entire directory
(including all subdirectories), retain all files of which the name ends with `.eb`, and (try to) use these
as easyconfig files.


### Example command

Suppose we have the current situation in our home directory:

* two (easyconfig) files named `example1.eb` and `example2.eb`;
* a subdirectory named `some_deps`, which has two easyconfig files `dep1.eb` and `dep2.eb`
  alongside a text file named `list.txt`;
* a subdirectory named `more_deps` located *in* the `some_deps` subdirectory,
  which contains another easyconfig file `dep3.eb`;

Or, visually represented:

```shell
example1.eb
example2.eb
some_deps/
|-- dep1.eb
|-- dep2.eb
|-- list.txt
|-- more_deps/
    |-- dep3.eb
```

In this context, we run the following EasyBuild command from our home directory:

```shell
eb example1.eb bzip2-1.0.6.eb $HOME/example2.eb some_deps
```

EasyBuild will interpret each of these arguments as follows:

* `example1.eb` is the name of a file in the current directory, so it can be used directly;
* `bzip2-1.0.6.eb` is the name of an easyconfig file to locate via the robot search path
  (since it does not exist in the current directory);
* `$HOME/example2.eb` specifies the full path to an existing file, which can be used directly;
* `some_deps` is the relative path to an existing directory, so EasyBuild will scan it and find three
  easyconfig files: `some_deps/dep1.eb`, `some_deps/dep2.eb` and `some_deps/more_deps/dep3.eb`,
  The `list.txt` file will be ignored since its name does not end with `.eb`.

---

### Easyconfig filenames

Note that the `eb` command does not care how easyconfig files are named, at least to some extent: the `.eb`
file extension *does* matter when easyconfig files are being picked up in subdirectories.

File names for easyconfigs being mostly irrelevant is only correct with respect to the arguments passed to
the `eb` command however. As we will learn soon, the name of easyconfig files *does* matter (a lot)
when EasyBuild needs to locate easyconfigs that can be used to resolve a specified dependency
(see [here](installing_software.md#enabling-dependency-resolution)).

This explains why easyconfig files usually adhere to a very specific naming scheme,
corresponding to `<name>-<version>-<toolchain><versionsuffix>.eb`, where:

* `<name>` represents the software name;
* `<version>` represents the software version;
* `<toolchain>` represents the toolchain used in the easyconfig file, which consists of the toolchain name
  and version separated with a dash (`-`), and which is omitted (including the preceding `-`) when the
  [`system` toolchain](terminology.md#system-toolchain) is used;
* `<versionsuffix>` represents the value of the `versionsuffix` easyconfig parameter,
  which is sometimes used to distinguish multiple variants of particular software installations
  (and is empty by default);

---

### Searching for easyconfigs

You will frequently need to determine the exact name of an easyconfig file you want to install,
or just check which easyconfigs are available for a given software package. 
This can be done by searching for easyconfigs using **`eb --search`** or **`eb -S`**.

By default all directories listed in the [robot search path](../configuration#robot-search-path) will be
searched. If you want to search in additional directories without changing the robot search path,
you can use the `search-paths` configuration setting, or you can change the robot search path via either
the `robot` or `robot-paths` configuration options.

Both the `--search` and `-S` options trigger the same search operation, but yield different output:
`eb --search` will print the full path to each easyconfig file that matches the specified search pattern,
while `eb -S` produces a more concise output.

For example, let's check which easyconfig files are available for OpenFOAM 8 with a `foss` toolchain:

```shell
$ eb --search openfoam-8-foss
 * /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-8-foss-2020a.eb
 * /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-8-foss-2020b-20210316.eb
 * /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-8-foss-2020b.eb
```

The output is a bit more condensed when using `eb -S`:

```shell
$ eb -S openfoam-8-foss
CFGS1=/home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/o/OpenFOAM
 * $CFGS1/OpenFOAM-8-foss-2020a.eb
 * $CFGS1/OpenFOAM-8-foss-2020b-20210316.eb
 * $CFGS1/OpenFOAM-8-foss-2020b.eb
```

Note that the search is performed *case-insensitive*.

The search pattern can include wildcards like `.*` and/or character groups like `[0-9]`,
or other special characters like `^` or `$` to mark the start/end of the filename,
but you need to be careful that `bash` does not expand these before the `eb` command is started,
so it is recommended to wrap the search pattern in single quotes (`'...'`) when using wildcards.

For example, to check which easyconfigs are available to install TensorFlow 2.6.0 with the `2021a` version of a toolchain:

```shell
$ eb -S '^tensorflow-2.6.0.*2021a'
CFGS1=/home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/t/TensorFlow
 * $CFGS1/TensorFlow-2.6.0-foss-2021a-CUDA-11.3.1.eb
 * $CFGS1/TensorFlow-2.6.0-foss-2021a.eb
```

---

#### Search index

When searching for easyconfig files, you may see a message like this pop up:

```
== found valid index for <path>, so using it...
```

This indicates that a **search index** was used for this particular directory which significantly speeds
up the search procedure, especially when the easyconfig files are located on a shared filesystem where metadata
operations involving lots of (small) files can be slow.

For the easyconfig files included with an EasyBuild release, a search index is readily provided.
For other directories, you can create a search index using `eb --create-index <path>`.
[See the EasyBuild documentation for more information](https://docs.easybuild.io/en/latest/Easyconfigs_index.html).

---

## Inspecting easyconfigs

Once you have determined the name of the easyconfig file that corresponds to the software you want to install,
you may want to take a closer look at its contents before employing it.

Since easyconfig files are simple text files (in Python syntax), you could use the ubiquitous `cat` command
or your favorite text editor (`vim`, what else). To avoid that you need to locate the easyconfig file first
and copy-paste the full path to it, you can use **`eb --show-ec`**.

For example, let's inspect the contents of the `bzip2-1.0.6.eb` easyconfig file:

```shell
$ eb --show-ec bzip2-1.0.8.eb
== temporary log file in case of crash /tmp/eb-jnpzclhl/easybuild-e37cbrj1.log
== Contents of /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/b/bzip2/bzip2-1.0.6.eb:
name = 'bzip2'
version = '1.0.8'

homepage = 'https://sourceware.org/bzip2'
description = """
 bzip2 is a freely available, patent free, high-quality data compressor. It
 typically compresses files to within 10% to 15% of the best available
 techniques (the PPM family of statistical compressors), whilst being around
 twice as fast at compression and six times faster at decompression.
"""

toolchain = SYSTEM
toolchainopts = {'pic': True}

source_urls = ['https://sourceware.org/pub/%(name)s/']
sources = [SOURCE_TAR_GZ]
patches = ['bzip2-%(version)s-pkgconfig.patch']
checksums = [
    'ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269',  # bzip2-1.0.8.tar.gz
    '9299e8ee4d014ea973777b6ea90661fe329dfa991f822add4c763ea9ddb9aab1',  # bzip2-1.0.8-pkgconfig.patch
]

builddependencies = [
    ('binutils', '2.37'),
]

buildopts = "CC=gcc CFLAGS='-Wall -Winline -O3 -fPIC -g $(BIGFILES)'"

# building of shared libraries doesn't work on OS X (where 'gcc' is actually Clang...)
with_shared_libs = OS_TYPE == 'Linux'

moduleclass = 'tools'

== Temporary log file(s) /tmp/eb-jnpzclhl/easybuild-e37cbrj1.log* have been removed.
== Temporary directory /tmp/eb-jnpzclhl has been removed.
```

We'll get back to what all of this means later...

---

## Checking dependencies

!!! note
    In some of the examples below, we assume that some software is already installed with EasyBuild.

    If you are following hands-on in a prepared environment, make sure these installations are visible
    in the output of "`module avail`" by informing the modules tool about the pre-installed software stack
    in `/easybuild`:

        module use /easybuild/modules/all


Before kicking off an installation, it is good practice to check which of the required dependencies
are already installed, and which ones are still missing.

This can be helpful to ensure that your EasyBuild configuration is set up correctly,
and to prevent from accidentally installing an entirely new software stack from scratch
in an unintended location (like `$HOME/.local/easybuild`, the
[default installation path](../configuration/#install-path)).

---

### Dry run

To get a complete overview of all required dependencies, and see which ones are already installed
and which ones aren't yet, you can use **`eb --dry-run`**.

Since `--dry-run` produces rather verbose output including the full path to each easyconfig file,
there is a more concise equivalent available as well: `eb --dry-run-short`, which is equivalent with **`eb -D`**.

For example, to check which of the required dependencies for `SAMtools-1.11-GCC-10.2.0.eb` are already installed:

```shell
$ eb SAMtools-1.14-GCC-11.2.0.eb -D
== temporary log file in case of crash /tmp/eb-x4qofiph/easybuild-ehhi9fb1.log
== found valid index for /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs, so using it...
Dry run: printing build status of easyconfigs and dependencies
CFGS=/home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs
 ...
 * [x] $CFGS/b/bzip2/bzip2-1.0.8-GCCcore-11.2.0.eb (module: bzip2/1.0.8-GCCcore-11.2.0)
 * [x] $CFGS/x/XZ/XZ-5.2.5-GCCcore-11.2.0.eb (module: XZ/5.2.5-GCCcore-11.2.0)
 * [x] $CFGS/g/GCC/GCC-11.2.0.eb (module: GCC/11.2.0)
 * [x] $CFGS/n/ncurses/ncurses-6.2-GCCcore-11.2.0.eb (module: ncurses/6.2-GCCcore-11.2.0)
 * [x] $CFGS/p/pkg-config/pkg-config-0.29.2.eb (module: pkg-config/0.29.2)
 * [x] $CFGS/o/OpenSSL/OpenSSL-1.1.eb (module: OpenSSL/1.1)
 * [x] $CFGS/c/cURL/cURL-7.78.0-GCCcore-11.2.0.eb (module: cURL/7.78.0-GCCcore-11.2.0)
 * [ ] $CFGS/s/SAMtools/SAMtools-1.14-GCC-11.2.0.eb (module: SAMtools/1.14-GCC-11.2.0)
```

(We've trimmed the output a bit here, for the sake of brevity.)

This output tells us that all dependencies required by `SAMtools-1.14-GCC-11.2.0.eb` are already installed,
since they are all marked with `[x]`, whereas the easyconfig for `SAMtools` itself is not installed yet,
as indicated by lack of an `x` in `[ ]`.

---

### Missing dependencies

If you are only interested in which dependencies are still *missing*,
you can consult the output of **`eb --missing`**, or the equivalent **`eb -M`**.

For example, let's see which dependencies are missing in order to get version 3.6.1 of the PyTables
Python package installed using the `2021b` version of the `foss` toolchain:

```shell
$ eb PyTables-3.6.1-foss-2021b.eb -M

3 out of 69 required modules missing:

* LZO/2.10-GCCcore-11.2.0 (LZO-2.10-GCCcore-11.2.0.eb)
* Blosc/1.21.1-GCCcore-11.2.0 (Blosc-1.21.1-GCCcore-11.2.0.eb)
* PyTables/3.6.1-foss-2021b (PyTables-3.6.1-foss-2021b.eb)
```

That should be pretty self-explanatory: out of the 69 required dependencies (which includes the `foss` toolchain
and everything needed to install it), only 3 dependencies are missing. Great!

---

## Inspecting install procedures

Finally, before actually installing something you may want to assess *how* exactly EasyBuild is going
to install the software.

Perhaps you don't trust EasyBuild yet (you will eventually though, hopefully),
or maybe you just want to double check that you have made the right choice before going through with
the actual installation.

Using **`eb --extended-dry-run`**, or just **`eb -x`** for short,
you can get a **detailed overview of the installation procedure that would be performed by EasyBuild**,
**in a matter of seconds**.

By means of example, let's inspect some parts of the installation procedure for `Boost-1.74.0-GCC-10.2.0.eb`:

```shell
$ eb Boost-1.77.0-GCC-11.2.0.eb -x
...

preparing... [DRY RUN]

[prepare_step method]
Defining build environment, based on toolchain (options) and specified dependencies...

Loading toolchain module...

module load GCC/11.2.0

Loading modules for dependencies...

module load bzip2/1.0.8-GCCcore-11.2.0
module load zlib/1.2.11-GCCcore-11.2.0
module load XZ/5.2.5-GCCcore-11.2.0

...

Defining build environment...

  ...
  export CXX='g++'
  export CXXFLAGS='-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC'
  ...

configuring... [DRY RUN]

[configure_step method]
  running command "./bootstrap.sh --with-toolset=gcc --prefix=/tmp/example/Boost/1.77.0-GCC-11.2.0 --without-libraries=python,mpi"
  (in /tmp/example/build/Boost/1.77.0/GCC-11.2.0/Boost-1.77.0)

...

[sanity_check_step method]
Sanity check paths - file ['files']
  * lib/libboost_system-mt-x64.so
  * lib/libboost_system.so
  * lib/libboost_thread-mt-x64.so
Sanity check paths - (non-empty) directory ['dirs']
  * include/boost
Sanity check commands
  (none)

...
```

We've obviously trimmed the generated output a bit, but it should be sufficient to explain what all this output means.

An overview of the installation procedure is shown, following the installation steps as they would be
performed by EasyBuild. The output above shows:

* how the build environment will be set up during the `prepare` step, by loading the module for both the
  toolchains and the dependencies, and defining a set of environment variables like `$CXX`, `$CXXFLAGS`, etc.
* which command will be executed during the configuration step, and in which directory;
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
    though, which will report any errors that occurred and then continue anyway with inspecting the remainder of the
    installation procedure. Although this obviously limits the value of the generated output,
    it doesn't make it completely useless.

## Exercises

***Guidelines***

Do yourself a favor: don't peek at the solution until you have made an attempt to solve the exercise yourself!

Please do not share solutions with others before they have been discussed by the tutorial organisers.

The exercises are based on the easyconfig files included with EasyBuild 4.5.4.

---

***Exercise U.0**** - Making installed software available*

Before working on the exercises for this part of the tutorial,
make sure that the software that is already installed in the prepared environment is available.

We will assume that you have a small software stack installed using the `2021b` version of the `foss` toolchain.

**Tip:** execute a "`module use`" command, and verify with "`module avail`" that a bunch of software modules
are available for loading.

??? success "(click to show solution)"

    Use the following command to make the modules for the software available that is pre-installed
    in the prepared environment:
    ```shell
    module use /easybuild/modules/all
    ```

    If software is installed in a different location than `/easybuild/` in your environment,
    you should adjust the command accordingly.

    To verify that the pre-installed software is available, check whether the `foss/2020b` module is available:
    ```shell
    $ module avail foss/

    --------------------- /easybuild/modules/all ---------------------
      foss/2021b
    ```

---

***Exercise U.1**** - Searching easyconfigs*

See if EasyBuild provides any easyconfig files for installing GROMACS version 2021.5.

??? success "(click to show solution)"
    To check for available easyconfig files, we can use `eb --search` or `eb -S`:
    ```shell
    $ eb -S gromacs-2021.5
    == found valid index for /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs, so using it...
    CFGS1=//home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/g/GROMACS
     * $CFGS1/GROMACS-2021.5-foss-2021b-CUDA-11.4.1.eb
     * $CFGS1/GROMACS-2021.5-foss-2021b.eb
     * $CFGS1/GROMACS-2021.5_fix_threads_gpu_Gmxapitests.patch
    ```
    This actually shows two easyconfig files but also a patch file. We can also search specifically
    for GROMACS 2021.5 in the `foss` and `fosscuda` toolchains using
    ```shell
    $ eb -S gromacs-2021.5-foss
    == found valid index for /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs, so using it...
    CFGS1=/home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/g/GROMACS
     * $CFGS1/GROMACS-2021.5-foss-2021b-CUDA-11.4.1.eb
     * $CFGS1/GROMACS-2021.5-foss-2021b.eb
    ```
    and now we find just the two easyconfig files.  

---

***Exercise U.2**** - Checking dependencies*

Check which dependencies are missing to install QuantumESPRESSO version 6.8 with the `2021b` version of the `foss` toolchain.

??? success "(click to show solution)"
    First, we need to determine the name of the easyconfig file for QuantumESPRESSO version 6.6:
    ```shell
    $ eb -S 'QuantumESPRESSO-6.8.*foss-2021b'
    == found valid index for /home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs, so using it...
    CFGS1=/home/example/easybuild/software/EasyBuild/4.5.4/easybuild/easyconfigs/q/QuantumESPRESSO
     * $CFGS1/QuantumESPRESSO-6.8-foss-2021b.eb
    ```
    To determine which dependencies are missing to install this QuantumESPRESSO easyconfig file, we can use `--missing`:
    ```shell
    $ eb QuantumESPRESSO-6.8-foss-2021b.eb --missing
    
    3 out of 65 required modules missing:
    
    * libxc/5.1.6-GCC-11.2.0 (libxc-5.1.6-GCC-11.2.0.eb)
    * ELPA/2021.05.001-foss-2021b (ELPA-2021.05.001-foss-2021b.eb)
    * QuantumESPRESSO/6.8-foss-2021b (QuantumESPRESSO-6.8-foss-2021b.eb)
    ```
    (some nonessential output removed).

---

***Exercise U.3**** - Performing a dry run*

Figure out which command EasyBuild would use to compile
the software provided by the `Bowtie2-2.4.4-GCC-11.2.0.eb` easyconfig file,
without actually installing `Bowtie2`.

Also, which binaries will EasyBuild check for to sanity check the installation?

??? success "(click to show solution)"
    To inspect the installation procedure, we can use `eb -x Bowtie2-2.4.4-GCC-11.2.0.eb`.

    The output for the build step shows the actual compilation command that would be performed (`make ...`):

    ```shell
    [build_step method]
    >> running command:
        [started at: 2021-03-08 20:15:08]
        [working dir: /tmp/eb-0006djcd/__ROOT__/tmp/example/Bowtie2/2.4.4/GCC-11.2.0/Bowtie2-2.4.4]
        [output logged in /tmp/eb-0006djcd/easybuild-run_cmd-haojzisn.log]
        make -j 8  CC="gcc"  CPP="g++" CXX="g++"  RELEASE_FLAGS="-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC -std=gnu++98"
    running command "make  -j 16  CC="gcc"  CPP="g++" CXX="g++"  RELEASE_FLAGS="-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC -std=gnu++98""
    (in /tmp/example/Bowtie2/2.4.4/GCC-11.2.0/Bowtie2-2.4.4)
    ```

    If the output you get is less detailed, you may not have set `export EASYBUILD_TRACE=1`.

    The output for the sanity check step shows which binaries are expected to be installed:
    ```
    [sanity_check_step method]
    Sanity check paths - file ['files']
      * bin/LICENSE
      * bin/MANUAL
      * bin/MANUAL.markdown
      * bin/NEWS
      * bin/bowtie2
      * bin/bowtie2-align-l
      * bin/bowtie2-align-s
      * bin/bowtie2-build
      * bin/bowtie2-build-l
      * bin/bowtie2-build-s
      * bin/bowtie2-inspect
      * bin/bowtie2-inspect-l
      * bin/bowtie2-inspect-s
    ```

---

[*next: Installing software*](installing_software.md) - [*(back to overview page)*](index.md)
