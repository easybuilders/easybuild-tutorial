# Basic usage

*[[back: Configuring EasyBuild]](1_07_configuration.md)*

---

Now that we have installed and configured EasyBuild, we can start using it for what it is intended for:
getting scientific software installed without breaking a sweat, or having to resist the urge to
shout out four-letter words.

We will look at the high-level workflow first, and then cover each aspect in more detail.

A couple of exercises are available at the end to help to make you more familiar with the
EasyBuild command line interface, so pay attention!

---

## Overall workflow

Installing software with EasyBuild is as easy as specifying to the **`eb` command** what we
want to install, and then sitting back to enjoy a coffee or tea (or whatever beverage you prefer).

This is typically done by **specifying the name of one or more easyconfig files**, often combined
with the `--robot` option to let EasyBuild also install missing dependencies.

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


#### Example command

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
(see [here](#enabling-dependency-resolution)).

This explains why easyconfig files usually adher to a very specific naming scheme,
corresponding to `<name>-<version>-<toolchain><versionsuffix>.eb`, where:

* `<name>` represents the software name;
* `<version>` represents the software version;
* `<toolchain>` represents the toolchain used in the easyconfig file, which consists of the toolchain name
  and version separated with a dash (`-`), and which is omitted (including the preceding `-`) when the
  [`system` toolchain](../introduction#system-toolchain) is used;
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
 * /home/example/.local/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-8-foss-2020a.eb
 * /home/example/.local/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-8-foss-2020b.eb
```

The output is a bit more condensed when using `eb -S`:

```shell
$ eb -S openfoam-8-foss
CFGS1=/home/example/.local/easybuild/easyconfigs/o/OpenFOAM
 * $CFGS1/OpenFOAM-8-foss-2020a.eb
 * $CFGS1/OpenFOAM-8-foss-2020b.eb
```

Note that the search is performed *case-insensitive*.

The search pattern can include wildcards like `.*` and/or character groups like `[0-9]`,
or other special characters like `^` or `$` to mark the start/end of the filename,
but you need to be careful that `bash` does not expand these before the `eb` command is started,
so it is recommended to wrap the search pattern in single quotes (`'...'`) when using wildcards.

For example, to check which easyconfigs are available to install TensorFlow 2.4.1 with the `2020b` version of a toolchain:

```shell
$ eb -S '^tensorflow-2.4.1.*2020b'
CFGS1=/home/example/.local/easybuild/easyconfigs/t/TensorFlow
 * $CFGS1/TensorFlow-2.4.1-foss-2020b.eb
 * $CFGS1/TensorFlow-2.4.1-fosscuda-2020b.eb
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
[See the EasyBuild documentation for more information](https://easybuild.readthedocs.io/en/latest/Easyconfigs_index.html).

---

## Inspecting easyconfigs

Once you have determined the name of the easyconfig file that corresponds to the software you want to install,
you may want to take a closer look at its contents before employing it.

Since easyconfig files are simple text files (in Python syntax), you could use the ubiquitous `cat` command
or your favorite text editor (`vim`, what else). To avoid that you need to locate the easyconfig file first
and copy-paste the full path to it, you can use **`eb --show-ec`**.

For example, let's inspect the contents of the `bzip2-1.0.6.eb` easyconfig file:

```shell
$ eb --show-ec bzip2-1.0.6.eb
== temporary log file in case of crash /tmp/eb-jnpzclhl/easybuild-e37cbrj1.log
== Contents of /home/example/.local/easybuild/easyconfigs/b/bzip2/bzip2-1.0.6.eb:
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

We'll get back to what all of this means later...

---

## Checking dependencies

!!! note
    In some of the examples below, we assume that some software is already installed with EasyBuild.

    If you are following hands-on in a prepared environment, make sure these installations are visible
    in the output of "`module avail`".


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
$ eb SAMtools-1.11-GCC-10.2.0.eb -D
== temporary log file in case of crash /tmp/eb-x4qofiph/easybuild-ehhi9fb1.log
== found valid index for /home/example/.local/easybuild/easyconfigs, so using it...
Dry run: printing build status of easyconfigs and dependencies
CFGS=/home/example/.local/easybuild/easyconfigs
 ...
 * [x] $CFGS/b/bzip2/bzip2-1.0.8-GCCcore-10.2.0.eb (module: bzip2/1.0.8-GCCcore-10.2.0)
 * [x] $CFGS/x/XZ/XZ-5.2.5-GCCcore-10.2.0.eb (module: XZ/5.2.5-GCCcore-10.2.0)
 * [x] $CFGS/c/cURL/cURL-7.72.0-GCCcore-10.2.0.eb (module: cURL/7.72.0-GCCcore-10.2.0)
 * [x] $CFGS/g/GCC/GCC-10.2.0.eb (module: GCC/10.2.0)
 * [x] $CFGS/n/ncurses/ncurses-6.2-GCCcore-10.2.0.eb (module: ncurses/6.2-GCCcore-10.2.0)
 * [ ] $CFGS/s/SAMtools/SAMtools-1.11-GCC-10.2.0.eb (module: SAMtools/1.11-GCC-10.2.0)
```

(We've trimmed the output a bit here, for the sake of brevity.)

This output tells us that all dependencies required by `SAMtools-1.11-GCC-10.2.0.eb` are already installed,
since they are all marked with `[x]`, whereas the easyconfig for `SAMtools` itself is not installed yet,
as indicated by lack of an `x` in `[ ]`.

---

### Missing dependencies

If you are only interested in which dependencies are still *missing*,
you can consult the output of **`eb --missing`**, or the equivalent **`eb -M`**.

For example, let's see which dependencies are missing in order to get version 3.1.0 of the h5py
Python package installed using the `2020b` version of the `foss` toolchain:

```shell
$ eb h5py-3.1.0-foss-2020b.eb -M

2 out of 61 required modules missing:

* pkgconfig/1.5.1-GCCcore-10.2.0-python (pkgconfig-1.5.1-GCCcore-10.2.0-python.eb)
* h5py/3.1.0-foss-2020b (h5py-3.1.0-foss-2020b.eb)
```

That should be pretty self-explanatory: out of the 63 required dependencies (which includes the `foss` toolchain
and everything needed to install it), only 2 dependencies are missing. Great!

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
$ eb Boost-1.74.0-GCC-10.2.0.eb -x
...

preparing... [DRY RUN]

[prepare_step method]
Defining build environment, based on toolchain (options) and specified dependencies...

Loading toolchain module...

module load GCC/10.2.0

Loading modules for dependencies...

module load bzip2/1.0.8-GCCcore-10.2.0
module load zlib/1.2.11-GCCcore-10.2.0
module load XZ/5.2.5-GCCcore-10.2.0

...

Defining build environment...

  ...
  export CXX='mpicxx'
  export CXXFLAGS='-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC'
  ...

configuring... [DRY RUN]

[configure_step method]
  running command "./bootstrap.sh --with-toolset=gcc --prefix=/tmp/example/Boost/1.74.0/GCC-10.2.0/obj --without-libraries=python,mpi"
  (in /tmp/example/build/Boost/1.74.0/GCC-10.2.0/Boost-1.74.0)

...

[sanity_check_step method]
Sanity check paths - file ['files']
  * lib/libboost_system.so
  * lib/libboost_thread-mt-x64.so
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

---

## Installing software

You should now be able to make an informed decision on which easyconfig file you should use to
make EasyBuild install the software you require.

As mentioned before, installing an easyconfig is as simple as passing it to the `eb` command.

So, let's try to install SAMtools version 1.11:

```shell
$ eb SAMtools-1.11-GCC-10.2.0.eb
== temporary log file in case of crash /tmp/eb-zh7_fyre/easybuild-4q_lo57b.log
== found valid index for /home/example/.local/easybuild/easyconfigs, so using it...
== processing EasyBuild easyconfig /home/example/.local/easybuild/easyconfigs/s/SAMtools/SAMtools-1.11-GCC-10.2.0.eb
== building and installing SAMtools/1.11-GCC-10.2.0...
== fetching files...
== creating build dir, resetting environment...
== unpacking...
== patching...
== preparing...
== configuring...
== building...
== testing...
== installing...
== taking care of extensions...
== restore after iterating...
== postprocessing...
== sanity checking...
== cleaning up...
== creating module...
== permissions...
== packaging...
== COMPLETED: Installation ended successfully (took 17 sec)
== Results of the build can be found in the log file(s) /home/example/easybuild/software/SAMtools/1.11-GCC-10.2.0/easybuild/easybuild-SAMtools-1.11-20210309.105601.log
== Build succeeded for 1 out of 1
== Temporary log file(s) /tmp/eb-zh7_fyre/easybuild-4q_lo57b.log* have been removed.
== Temporary directory /tmp/eb-zh7_fyre has been removed.
```

That was... easy. Is that really all there is to it? Well, almost...

### Enabling dependency resolution

The SAMtools installation worked like a charm, but remember that all required dependencies were already
available (see [above](#dry-run)).

If we try this with the `BCFtools-1.11-GCC-10.2.0.eb`, for which the required `GSL` and `HTSlib` dependencies are not available yet, it's less successful:

```shell
$ eb BCFtools-1.11-GCC-10.2.0.eb -M

3 out of 23 required modules missing:

* GSL/2.6-GCC-10.2.0 (GSL-2.6-GCC-10.2.0.eb)
* HTSlib/1.11-GCC-10.2.0 (HTSlib-1.11-GCC-10.2.0.eb)
* BCFtools/1.11-GCC-10.2.0 (BCFtools-1.11-GCC-10.2.0.eb)
```

```shell
$ eb BCFtools-1.11-GCC-10.2.0.eb
...
== preparing...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/build/BCFtools/1.11/GCC-10.2.0): build failed (first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.11-GCC-10.2.0, GSL/2.6-GCC-10.2.0 (took 2 sec)
== Results of the build can be found in the log file(s) /tmp/eb-3v1dfvnk/easybuild-BCFtools-1.11-20210308.195024.FlxkH.log
ERROR: Build of /home/example/.local/easybuild/easyconfigs/b/BCFtools/BCFtools-1.11-GCC-10.2.0.eb failed (err: 'build failed (first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.11-GCC-10.2.0, GSL/2.6-GCC-10.2.0')
```

Oh my, what's this all about?

If we filter the output a bit and focus on the actual error, the problem is clear:

```
Missing modules for dependencies (use --robot?): HTSlib/1.11-GCC-10.2.0, GSL/2.6-GCC-10.2.0
```

The required dependencies `HTSlib/1.11-GCC-10.2.0` and `GSL/2.6-GCC-10.2.0` are not installed yet,
and EasyBuild does not automatically install missing dependencies unless it is told to do so.

It helpfully suggests to use the `--robot` command line option, so let's try that:

```shell
$ eb BCFtools-1.11-GCC-10.2.0.eb --robot
...
== resolving dependencies ...
...
== building and installing HTSlib/1.11-GCC-10.2.0...
...
== COMPLETED: Installation ended successfully (took 13 sec)
...
== building and installing GSL/2.6-GCC-10.2.0...
...
== COMPLETED: Installation ended successfully (took 1 min 10 sec)
...
== building and installing BCFtools/1.11-GCC-10.2.0...
...
== COMPLETED: Installation ended successfully (took 8 sec)
...
== Build succeeded for 3 out of 3
```

With dependency resolution enabled the `HTSlib` and `GSL` modules get installed first,
before EasyBuild proceeds with installing `BCFtools`. Great!

---

### Trace output

As you may have noticed if you tried the previous example hands-on,
some installations take a while.
An installation can be spending quite a bit of time during the build step, but what is actually going on there?

To provide some more feedback as the installation progresses, you can enable the "`trace`" configuration setting.
Let's do this by defining the `$EASYBUILD_TRACE` environment variable, just to avoid having to type `--trace`
over and over again.

We will redo the installation of `BCFtools-1.11-GCC-10.2.0.eb` by passing the `--rebuild`
option to the `eb` command (try yourself what happens if you don't use the `--rebuild` option!):

```shell
$ export EASYBUILD_TRACE=1
$ eb BCFtools-1.11-GCC-10.2.0.eb --rebuild
...
== configuring...
  >> running command:
	[started at: 2021-03-08 19:54:53]
	[working dir: /tmp/example/build/BCFtools/1.11/GCC-10.2.0/bcftools-1.11]
	[output logged in /tmp/eb-9u_ac0nv/easybuild-run_cmd-17m_he2x.log]
	./configure --prefix=/home/example/easybuild/software/BCFtools/1.11-GCC-10.2.0  --build=x86_64-pc-linux-gnu  --host=x86_64-pc-linux-gnu --with-htslib=$EBROOTHTSLIB --enable-libgsl
== building...
  >> running command:
	[started at: 2021-03-08 19:54:54]
	[working dir: /tmp/example/BCFtools/1.11/GCC-10.2.0/bcftools-1.11]
	[output logged in /tmp/example/eb-9u_ac0nv/easybuild-run_cmd-bhkgjxi7.log]
	make -j 8
  >> command completed: exit 0, ran in 00h00m03s
```

That's a bit more comforting to stare at...

During the *configure* step, the `./configure` command is run with option to
enable support for leveraging `HTSlib` and `GSL`.

During the *build* step, the software is actually being compiled
by running the `make` command. EasyBuild automatically uses the available cores on the system (in this case 8).

We even get a pointer to a log file that contains the output of the command being run,
so we can use `tail -f` to see in detail how it progresses.

Once the `make` command completes, we get a message that the command completed with a exit code 0
(implying success), and that it took 3 seconds to run. That's good to know.

Later during the installation, we now also see this output during the sanity check step:

```
== sanity checking...
  >> file 'bin/bcftools' found: OK
  >> file 'bin/plot-vcfstats' found: OK
  >> file 'bin/vcfutils.pl' found: OK
  >> (non-empty) directory 'libexec/bcftools' found: OK
```

Thanks to enabling trace mode, EasyBuild tells us which files & directories it is checking for
in the installation, before declaring it a success. Nice!

The extra output you get when trace mode is enabled is concise and hence not overwhelming,
while it gives a better insight into what is going on during the installation.
It may also help to spot unexpected actions being taken during the installation early on,
so you can interrupt the installation before it completes, if deemed necessary.

---

## Using installed software

So far, we have already installed 4 different software packages (SAMtools, HTSlib, GSL, and BCFtools);
we even installed BCFtools twice!

A lot was going on underneath the covers: locating and unpacking
the source tarballs, setting up the build environment, configuring the build, compiling,
creating and populating the installation directory, performing a quick sanity check on the installation,
cleaning things up, and finally generated the environment module file corresponding to the installation.

That's great, but how do we now actually *use* these installations?

This is where the generated module files come into play: they form the access portal to the software
installations, and we'll use the ubiquitous `module` command to digest them.

First, we need to make sure that the modules tool is aware of where the module files for
our installations are located. If you're unsure where EasyBuild is installing stuff at this point,
check the output of `eb --show-config`; the value of the `installpath` configuration setting is what we are interested in now:

```shell
$ eb --show-config
...
installpath    (E) = /home/example/easybuild
...
repositorypath (E) = /home/example/easybuild/ebfiles_repo
...
sourcepath     (E) = /home/example/easybuild/sources
...
```

So, what's in this directory?

```shell
$ ls -l $HOME/easybuild
total 16
drwxrwxr-x 5 example example 4096 Jun 10 20:11 ebfiles_repo
drwxrwxr-x 5 example example 4096 Jun 10 20:10 modules
drwxrwxr-x 6 example example 4096 Jun 10 20:10 software
drwxrwxr-x 6 example example 4096 Jun 10 20:10 sources
```

The `ebfiles_repo` and `sources` directories correspond to the `repositorypath` and `sourcepath` configuration
settings, respectively. The `modules` and `software` directories are what we need now.

The `modules` subdirectory consists of multiple subdirectories:

```shell
$ ls $HOME/easybuild/modules
all  bio  devel  numlib  tools
```

Directories like `bio` and `numlib` correspond to different software categories,
and contain symbolic links to the module files in the `all` directory,
which contains all actual module files for software installed in this EasyBuild installation path.
We'll ignore these separate category directories for now.

Let's inform the modules tool about the existence of these module files using `"module use"`:

```shell
module use $HOME/easybuild/modules/all
```

This command does little more that updating the `$MODULEPATH` environment variable,
which contains a list of paths that the modules tool should consider when looking for module files.

Now the modules tool should be aware of our brand new installations:

```shell
$ module avail

---------------------- /home/example/easybuild/modules/all -----------------------
   BCFtools/1.11-GCC-10.2.0    GSL/2.6-GCC-10.2.0       SAMtools/1.11-GCC-10.2.0
   EasyBuild/4.3.3             HTSlib/1.11-GCC-10.2.0   bzip2/1.0.6

---------------------------- /easybuild/modules/all -----------------------------
    ...
```

This output shows both the modules for our own installations as well as the "central" installations in `/easybuild` (which we omitted above for brevity).

Now we can load these modules and start using these software installations.

Let's test this for BCFtools. In our current environment, the `bcftools` command is not available yet:

```shell
$ module list
No modules loaded

$ bcftools
-bash: bcftools: command not found
```

Loading the module for BCFtools changes that:

```shell
$ module load BCFtools/1.11-GCC-10.2.0

$ module list
Currently Loaded Modules:
  1) GCCcore/10.2.0                 6) XZ/5.2.5-GCCcore-10.2.0
  2) zlib/1.2.11-GCCcore-10.2.0     7) cURL/7.72.0-GCCcore-10.2.0
  3) binutils/2.35-GCCcore-10.2.0   8) HTSlib/1.11-GCC-10.2.0
  4) GCC/10.2.0                     9) GSL/2.6-GCC-10.2.0
  5) bzip2/1.0.8-GCCcore-10.2.0    10) BCFtools/1.11-GCC-10.2.0

$ bcftools --version
bcftools 1.11
Using htslib 1.11
...
```

Note that the modules for the required dependencies, including the compiler toolchain (which provides runtime libraries
like `libstdc++.so`), are loaded automatically. The "`module load`" command changes the active environment,
by updating environment variables like `$PATH` for example, to make the software available for use.

##### Resetting your environment

To restore your environment to a pristine state in which no modules are loaded, you can either
unload the loaded modules one by one using "`module unload`", or you can unload all of them at once using
"`module purge`".

**If you are using an EasyBuild installation provided by a module,
don't forget to load the `EasyBuild` module again after running "`module purge`".**

---

## Stacking software

Maybe you have overlooked how the software we are playing around with was not only installed across multiple
different installation directories per software, we are also "stacking" our own installations (in `$HOME/easybuild`)
on top of installations that are provided in a totally different location (`/easybuild`).

**EasyBuild doesn't care *where* software is installed: as long as the module file that provides access to it
is available, it is happy to pick it up and use it when required.**

This implies that end users of an HPC system can easily install their
own small software stack on top of what is provided centrally by the HPC support team,
for example. They can even
"replace" a central software installation for their purposes if they need to, since the modules tool will
load the first module file that matches the request being made (there are some caveats with this, but we
won't go into those here).

---

## Exercises

***Guidelines***

Do yourself a favor: don't peek at the solution until you have made an attempt to solve the exercise yourself!

Please do not spoil solutions to others before they have been discussed by the tutorial organisers.

The exercises are based on the easyconfig files included with EasyBuild 4.3.3.

---

***Exercise U.0**** - Making installed software available*

Before working on the exercises for this part of the tutorial,
make sure that the software that is already installed in the prepared environment is available.

We will assume that you have a small software stack installed using the `2020b` version of the `foss` toolchain.

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
    

---

***Exercise U.1**** - Searching easyconfigs*

See if EasyBuild provides any easyconfig files for installing GROMACS version 2020/5.

??? success "(click to show solution)"
    To check for available easyconfig files, we can use `eb --search` or `eb -S`:
    ```shell
    $ eb -S gromacs-2020.5
    == found valid index for /home/example/.local/easybuild/easyconfigs, so using it...
    CFGS1=/home/example/.local/easybuild/easyconfigs/g/GROMACS
     * $CFGS1/GROMACS-2020.5-fosscuda-2020a-Python-3.8.2.eb
     * $CFGS1/GROMACS-2020.5_fix_threads_gpu_Gmxapitests.patch
    ```
    This actually shows one easyconfig file but also a patch file. We can also search specifically
    for GROMACS 2020.5 in the `foss` and `fosscuda` toolchains using
    ```shell
    $ eb -S gromacs-2020.5-foss
    == found valid index for /home/example/.local/easybuild/easyconfigs, so using it...
    CFGS1=/home/example/.local/easybuild/easyconfigs/g/GROMACS
     * $CFGS1/GROMACS-2020.5-fosscuda-2020a-Python-3.8.2.eb
    ```
    and now we find a single easyconfig file.  

---

***Exercise U.2**** - Checking dependencies*

Check which dependencies are missing to install QuantumESPRESSO version 6.6 with the `2020b` version of the `foss` toolchain.

??? success "(click to show solution)"
    First, we need to determine the name of the easyconfig file for QuantumESPRESSO version 6.6:
    ```shell
    $ eb -S 'QuantumESPRESSO-6.6.*foss-2020b'
    == found valid index for /home/example/.local/easybuild/easyconfigs, so using it...
    CFGS1=/home/example/.local/easybuild/easyconfigs/q/QuantumESPRESSO
     * $CFGS1/QuantumESPRESSO-6.6-foss-2020b.eb
    ```
    To determine which dependencies are missing to install this QuantumESPRESSO easyconfig file, we can use `--missing`:
    ```shell
    $ eb QuantumESPRESSO-6.6-foss-2020b.eb --missing
    
    3 out of 58 required modules missing:
    
    * libxc/4.3.4-GCC-10.2.0 (libxc-4.3.4-GCC-10.2.0.eb)
    * ELPA/2020.11.001-foss-2020b (ELPA-2020.11.001-foss-2020b.eb)
    * QuantumESPRESSO/6.6-foss-2020b (QuantumESPRESSO-6.6-foss-2020b.eb)
    ```
    (some nonessential output removed).

---

***Exercise U.3**** - Performing a dry run*

Figure out which command EasyBuild would use to compile
the software provided by the `Bowtie2-2.4.2-GCC-9.3.0.eb` easyconfig file,
without actually installing `Bowtie2`.

Also, which binaries will EasyBuild check for to sanity check the installation?

??? success "(click to show solution)"
    To inspect the installation procedure, we can use `eb -x Bowtie2-2.4.2-GCC-9.3.0.eb`.

    The output for the build step shows the actual compilation command that would be performed (`make ...`):

    ```shell
    [build_step method]
    >> running command:
        [started at: 2021-03-08 20:15:08]
        [working dir: /local_scratch/hkenneth/eb-1wodfohg/__ROOT__/local_scratch/hkenneth/Bowtie2/2.4.2/GCC-9.3.0/Bowtie2-2.4.2]
        [output logged in /local_scratch/hkenneth/eb-1wodfohg/easybuild-run_cmd-haojzisn.log]
        make -j 48  CC="gcc"  CPP="g++" CXX="g++"  RELEASE_FLAGS="-O2 -ftree-vectorize -march=native -fno-math-errno -fPIC -std=gnu++98"
    (in /local_scratch/hkenneth/Bowtie2/2.4.2/GCC-9.3.0/Bowtie2-2.4.2)
    ```

    If the output you get is less detailed, you may not have set `export EASYBUILD_TRACE=1`.

    The output for the sanity check step shows which binaries are expected to be installed:
    ```
    [sanity_check_step method]
    Sanity check paths - file ['files']
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

***Exercise U.4**** - Installing software*

Install version 3.1.0 of the `h5py` Python package and all missing dependencies,
using the `foss/2020b` toolchain, into `/tmp/$USER/easybuild`,
while leveraging the already installed software available from `/easybuild`.

Enable trace output so you can see which parts of the installation take a while.

??? success "(click to show solution)"
    First, determine the easyconfig file we can use for this:
    ```shell
    $ eb -S 'h5py-3.1.0.*foss-2020b'
    CFGS1=/home/example/.local/easybuild/easyconfigs/h/h5py
    * $CFGS1/h5py-3.1.0-foss-2020b.eb
    ```

    Make sure the pre-install software in `/easybuild/` is available:
    ```shell
    module use /easybuild/modules/all
    ```

    Check which dependencies are missing to install this `h5py` easyconfig:
    ```shell
    $ eb h5py-3.1.0-foss-2020b.eb --missing

    2 out of 63 required modules missing:

    * pkgconfig/1.5.1-GCCcore-10.2.0-python (pkgconfig-1.5.1-GCCcore-10.2.0-python.eb)
    * h5py/3.1.0-foss-2020b (h5py-3.1.0-foss-2020b.eb)
    ```

    Install `h5py` by specifying the easyconfig file and enabling dependency resolution via `--robot`,
    while indicating that we want to install the software into `/tmp/$USER/easybuild` using the `--installpath`
    option. Also make sure that trace mode is enabled by defining the `$EASYBUILD_TRACE` environment variable.
    ```shell
    $ export EASYBUILD_TRACE=1
    $ eb h5py-3.1.0-foss-2020b.eb --robot --installpath /tmp/$USER/easybuild
    ...
    == building and installing pkgconfig/1.5.1-GCCcore-10.2.0-python...
    ...
    == building and installing h5py/3.1.0-foss-2020b...
    ...
    == building...
      >> running command:
            [started at: 2020-06-10 21:47:32]
            [working dir: /tmp/example/h5py/3.1.0/foss-2020b/h5py-3.1.0]
            [output logged in /tmp/eb-rjjkbqe1/easybuild-run_cmd-d_dkc4iz.log]  
            python setup.py configure --mpi --hdf5=$EBROOTHDF5 && /easybuild/software/Python/3.8.6-GCCcore-10.2.0/bin/python setup.py build
      >> command completed: exit 0, ran in 00h01m27s
    ...
    == COMPLETED: Installation ended successfully (took 2 min 46 sec)
    ...
    == Build succeeded for 2 out of 2
    ```

    The trace output shows that most time is spent in the build command,
    which runs both `python setup.py configure` and `python setup.py build`.

---

***Exercise U.5**** - Using installed software*

Using the `h5py` installation from the previous exercise to create an empty HDF5 file,
using the following Python statements:

```python
import h5py
f = h5py.File("empty.hdf5", "w")
f.close()
```

Check the resulting file using the `h5stat` command.

??? success "(click to show solution)"
    First, we need to make the modules tool aware of the module files that were installed into `/tmp/$USER/easybuild`:
    ```shell
    module use /tmp/$USER/easybuild/modules/all
    ```

    Then we can check the `h5py` module is available, and load it:
    ```shell
    $ module avail h5py
    ------------ /tmp/example/easybuild/modules/all ------------
    h5py/3.1.0-foss-2020b
    ```

    ```shell
    module load h5py/3.1.0-foss-2020b
    ```
    
    The Python code snippet can be run directly on the command line using "`python -c '...'`", since it's tiny:
    ```shell
    python -c 'import h5py; f = h5py.File("empty.hdf5", "w"); f.close()'
    ```
    Of course you can also copy the Python code snippet in a file named `test_h5py.py`,
    and then run it with `python test_h5py.py`.

    Checking with the `h5stat` command shows that the resulting `empty.hdf5` is indeed a valid HDF5 file:
    ```shell
    $ ls -l empty.hdf5 
    -rw-rw-r-- 1 example example 800 Jun 10 21:54 empty.hdf5

    $ h5stat empty.hdf5
    Filename: empty.hdf5
    File information
            # of unique groups: 1
            # of unique datasets: 0
    ...
    ```

---

If you've made it through the hands-on exercises, congratulations!

If not, don't worry too much about it. We covered a lot of ground here,
and it's a lot to take in at once, take your time...

Feel free to ask question in the `#tutorial` channel in the [EasyBuild
Slack](https://docs.easybuild.io/en/latest/#getting-help),
we're happy to help!

---

*[[next: Part 2: Using EasyBuild]](2_00_part2_using.md)*
