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
with the `--robot` (or `-r`) option to let EasyBuild also install missing dependencies.

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
EasyBuild will search for the easyconfig file in the [robot search path](../1_07_configuration/#robot-search-path).

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
some_deps
├── deb2.eb
├── dep1.eb
├── list.txt
└── more_deps
    └── dep3.eb
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
  [`system` toolchain](../1_05_terminology#system-toolchain) is used;
* `<versionsuffix>` represents the value of the `versionsuffix` easyconfig parameter,
  which is sometimes used to distinguish multiple variants of particular software installations
  (and is empty by default);

---

### Searching for easyconfigs

You will frequently need to determine the exact name of an easyconfig file you want to install,
or just check which easyconfigs are available for a given software package. 
This can be done by searching for easyconfigs using **`eb --search`** or **`eb -S`**.

By default all directories listed in the [robot search path](../1_07_configuration#robot-search-path) will be
searched. If you want to search in additional directories without changing the robot search path,
you can use the `search-paths` configuration setting, or you can change the robot search path via either
the `robot` or `robot-paths` configuration options.

Both the `--search` and `-S` options trigger the same search operation, but yield different output:
`eb --search` will print the full path to each easyconfig file that matches the specified search pattern,
while `eb -S` produces a more concise output.

For example, let's check which easyconfig files are available for OpenFOAM 8 with a `foss` toolchain:

```shell
$ eb --search openfoam-9
 * /appl/lumi/LUMI-EasyBuild-contrib/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-9-cpeGNU-21.08.eb
 * /appl/lumi/LUMI-EasyBuild-contrib/easybuild/easyconfigs/o/OpenFOAM/OpenFOAM-9-cpeGNU-21.12.eb
```

The output is a bit more condensed when using `eb -S`:

```shell
$ eb -S openfoam-9
CFGS1=/appl/lumi/LUMI-EasyBuild-contrib/easybuild/easyconfigs/o/OpenFOAM
 * $CFGS1/OpenFOAM-9-cpeGNU-21.08.eb
 * $CFGS1/OpenFOAM-9-cpeGNU-21.12.eb
```

Note that the search is performed *case-insensitive*.

The search pattern can include wildcards like `.*` and/or character groups like `[0-9]`,
or other special characters like `^` or `$` to mark the start/end of the filename,
but you need to be careful that `bash` does not expand these before the `eb` command is started,
so it is recommended to wrap the search pattern in single quotes (`'...'`) when using wildcards.

For example, to check which easyconfigs are available to install GROMACS 2021 and subversions with 
the `cpeGNU` toolchains:

```shell
$ eb -S '^gromacs-2021.*cpeGNU.*'
CFGS1=/appl/lumi/LUMI-EasyBuild-contrib/easybuild/easyconfigs/g/GROMACS
 * $CFGS1/GROMACS-2021-cpeGNU-21.08-PLUMED-2.7.2-CPU.eb
 * $CFGS1/GROMACS-2021.3-cpeGNU-21.08-CPU.eb
 * $CFGS1/GROMACS-2021.4-cpeGNU-21.12-PLUMED-2.7.4-CPU.eb
 * $CFGS1/GROMACS-2021.4-cpeGNU-21.12-PLUMED-2.8.0-CPU.eb
 * $CFGS1/GROMACS-2021.5-cpeGNU-21.12-CPU.eb
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

!!! Hint 
    To follow the examples below on LUMI, load ``LUMI/21.12`` and ``EasyBuild-user``
    (though results may differ or the examples not work anymore as the software installation
    on LUMI evolves).

For example, let's inspect the contents of the `bzip2-1.0.6.eb` easyconfig file:

```shell
$ eb --show-ec bzip2-1.0.8-cpeCray-21.12.eb
== Temporary log file in case of crash /run/user/10012026/easybuild/tmp/eb-53o823qb/easybuild-xn6nmt61.log
== Contents of /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/bzip2/bzip2-1.0.8-cpeCray-21.12.eb:
# Contributed by Kurt Lust, LUMI project & UAntwerpen

local_bzip2_version =        '1.0.8'         # http://www.bzip.org/downloads.html

name =    'bzip2'
version = local_bzip2_version

homepage = 'https://www.sourceware.org/bzip2/'

whatis = [
    'Description: bzip2 is a freely available, patent free, high-quality data compressor.',
    'The module contains both executables and libraries.'
    'Keywords: BZ2',
]

description = """
bzip2 is a freely available, patent free, high-quality data compressor. It
typically compresses files to within 10% to 15% of the best available techniques
(the PPM family of statistical compressors), whilst being around twice as fast
at compression and six times faster at decompression. It is based on the
Burrows-Wheeler block-sorting text compression algorithm and Huffman coding.
"""

usage = """
Check the man pages for the available commands or the web-based documentation for the
library functions.
"""

docurls = [
    'Web-based documentation: http://www.bzip.org/docs.html',
    'Man pages available for bzcmp, bzdiff, bzegrep, bzfgrep, bzgrep, bzip2, bunzip2, bzless and bzmore',
]

toolchain = {'name': 'cpeCray', 'version': '21.12'}
toolchainopts = {'pic': True}

source_urls = ['https://sourceware.org/pub/%(name)s/']
sources =     [SOURCE_TAR_GZ]
patches =     ['bzip2-%(version)s-pkgconfig-manpath.patch']
checksums = [
    'ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269',  # bzip2-1.0.8.tar.gz
    'de11269dc6e4917023af4cee9ff83b204953ad9cde561dbc9d6fc70d9b9578e3',  # bzip2-1.0.8-pkgconfig-manpath.patch
]

builddependencies = [ # Create a reproducible build environment.
    ('buildtools', '%(toolchain_version)s', '', True),
]

local_bzip2_major_minor =  '.'.join(local_bzip2_version.split('.')[:2])

sanity_check_paths = {
    'files': [ 'lib/pkgconfig/bzip2.pc', 'lib/libbz2.a', 'lib/libbz2.%s' % SHLIB_EXT,
               'lib/libbz2.%s.%s' % (SHLIB_EXT, local_bzip2_major_minor),
               'lib/libbz2.%s.%s' % (SHLIB_EXT, local_bzip2_version),
               'include/bzlib.h' ] +
             [ 'bin/b%s' % x for x in ['unzip2', 'zcat', 'zdiff', 'zgrep', 'zip2', 'zip2recover', 'zmore'] ] +
             [ 'share/man/man1/bz%s.1' % x for x in ['cmp', 'diff', 'egrep', 'fgrep', 'grep', 'ip2', 'less', 'more'] ],
    'dirs':  []
}

sanity_check_commands = [
    'bzip2 --help',
    'pkg-config --libs bzip2',
]

moduleclass = 'tools'

== Temporary log file(s) /run/user/10012026/easybuild/tmp/eb-53o823qb/easybuild-xn6nmt61.log* have been removed.
== Temporary directory /run/user/10012026/easybuild/tmp/eb-53o823qb has been removed.
```
The output may actually be longer for an easyconfig file that is already installed on the system 
as a new easyconfig file is generated in the repository with some information about the installation
added to it and as on LUMI these are at the front of the robot search path to ensure that the system
finds the right easyconfig file matching with a module on the system.

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
[default installation path](../1_07_configuration/#install-path)).

---

### Dry run

To get a complete overview of all required dependencies, and see which ones are already installed
and which ones aren't yet, you can use **`eb --dry-run`**.

Since `--dry-run` produces rather verbose output including the full path to each easyconfig file,
there is a more concise equivalent available as well: `eb --dry-run-short`, which is equivalent with **`eb -D`**.

For example, to check which of the required dependencies for `SAMtools-1.11-GCC-10.2.0.eb` are already installed:

```shell
$ eb SAMtools-1.14-cpeGNU-21.12.eb -D
== Temporary log file in case of crash /run/user/10012026/easybuild/tmp/eb-oo0lj9lq/easybuild-2cyomy8v.log
Dry run: printing build status of easyconfigs and dependencies
CFGS=/appl/lumi
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-common/buildtools/buildtools-21.12.eb (module: buildtools/21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/cpeGNU/cpeGNU-21.12.eb (module: cpeGNU/21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/ncurses/ncurses-6.2-cpeGNU-21.12.eb (module: ncurses/6.2-cpeGNU-21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/zlib/zlib-1.2.11-cpeGNU-21.12.eb (module: zlib/1.2.11-cpeGNU-21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/bzip2/bzip2-1.0.8-cpeGNU-21.12.eb (module: bzip2/1.0.8-cpeGNU-21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/gettext/gettext-0.21-cpeGNU-21.12-minimal.eb (module: gettext/0.21-cpeGNU-21.12-minimal)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/XZ/XZ-5.2.5-cpeGNU-21.12.eb (module: XZ/5.2.5-cpeGNU-21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/Brotli/Brotli-1.0.9-cpeGNU-21.12.eb (module: Brotli/1.0.9-cpeGNU-21.12)
 * [x] $CFGS/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/cURL/cURL-7.78.0-cpeGNU-21.12.eb (module: cURL/7.78.0-cpeGNU-21.12)
 * [ ] $CFGS/LUMI-EasyBuild-contrib/easybuild/easyconfigs/h/HTSlib/HTSlib-1.14-cpeGNU-21.12.eb (module: HTSlib/1.14-cpeGNU-21.12)
 * [ ] $CFGS/LUMI-EasyBuild-contrib/easybuild/easyconfigs/s/SAMtools/SAMtools-1.14-cpeGNU-21.12.eb (module: SAMtools/1.14-cpeGNU-21.12)
== Temporary log file(s) /run/user/10012026/easybuild/tmp/eb-oo0lj9lq/easybuild-2cyomy8v.log* have been removed.
== Temporary directory /run/user/10012026/easybuild/tmp/eb-oo0lj9lq has been removed.
```

This output tells you that most of the dependencies required by ``SAMtools-1.14-cpeGNU-21.12.eb`` are
already installed, since they are marked with ``[x]``. However, the easyconfig files for 
``HTSLib-1.14-cpeGNU-21.12.eb`` and SAMtools itself are not installed yet, denoted by the
lack of an ``x`` in ``[ ]``. 


---

### Missing dependencies

If you are only interested in which dependencies are still *missing*,
you can consult the output of **`eb --missing`**, or the equivalent **`eb -M`**.

For example, for the SAMtools easyconfig file used in the previous example we get (with
some lines removed from the output):

```shell
$ eb SAMtools-1.14-cpeGNU-21.12.eb -M
2 out of 11 required modules missing:

* HTSlib/1.14-cpeGNU-21.12 (HTSlib-1.14-cpeGNU-21.12.eb)
* SAMtools/1.14-cpeGNU-21.12 (SAMtools-1.14-cpeGNU-21.12.eb)
```

That should be pretty self-explanatory: out of the 113 required dependencies (which includes the `cpeGNU` toolchain
and everything needed to install it), only 2 dependencies (including SAMtools itself) are missing. Great!

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

By means of example, let's inspect some parts of the installation procedure for ``HTSLib-1.14-cpeGNU-21.12.eb``:

```shell
$ eb HTSlib-1.14-cpeGNU-21.12.eb -x
...

*** DRY RUN using 'ConfigureMake' easyblock (easybuild.easyblocks.generic.configuremake @ /appl/lumi/SW/LUMI-21.12/common/EB/EasyBuild/4.5.3/lib/python3.6/site-packages/easybuild/easyblocks/generic/configuremake.py) ***

== building and installing HTSlib/1.14-cpeGNU-21.12...
fetching files... [DRY RUN]

...

[prepare_step method]
Defining build environment, based on toolchain (options) and specified dependencies...

Loading toolchain module...

module load cpeGNU/21.12

Loading modules for dependencies...

module load buildtools/21.12
module load zlib/1.2.11-cpeGNU-21.12
module load bzip2/1.0.8-cpeGNU-21.12
module load XZ/5.2.5-cpeGNU-21.12
module load cURL/7.78.0-cpeGNU-21.12

...

Defining build environment...

...

  export CC='cc'
  export CFLAGS='-O2 -ftree-vectorize -fno-math-errno'

...

configuring... [DRY RUN]

[configure_step method]
  running command "./configure --prefix=/users/kurtlust/LUMI-user-appl/SW/LUMI-21.12/L/HTSlib/1.14-cpeGNU-21.12"
  (in /run/user/10012026/easybuild/build/HTSlib/1.14/cpeGNU-21.12/HTSlib-1.14)

building... [DRY RUN]

[build_step method]
  running command "make  -j 256"
  (in /run/user/10012026/easybuild/build/HTSlib/1.14/cpeGNU-21.12/HTSlib-1.14)

testing... [DRY RUN]

[test_step method]

installing... [DRY RUN]

...

sanity checking... [DRY RUN]

[sanity_check_step method]
Sanity check paths - file ['files']
  * bin/bgzip
  * bin/tabix
  * lib/libhts.so
Sanity check paths - (non-empty) directory ['dirs']
  * include
Sanity check commands
  * bgzip --version
  * htsfile --version
  * tabix --version

...
```

We've obviously trimmed the generated output a bit, but it should be sufficient.

An overview of the installation procedure is shown, following the installation steps as they would be
performed by EasyBuild. The output above shows:

* how the build environment will be set up during the `prepare` step, by loading the module for both the
  toolchains and the dependencies, and defining a set of environment variables like `$CC`, `$CFLAGS`, etc.
* which command will be executed during the configuration step, and in which directory;
* the list of files and directories that will be checked during the sanity check step;

If you were concerned about EasyBuild being too much of a black box, that is hopefully resolved now.

!!! note
    It is important to highlight here that the reported installation procedure *may* not be 100% correct,
    since the [easyblock](1_05_terminology.md#easyblocks) can change its mind based on the output of shell commands
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

So, let's try to install libdap version 3.20.9 with the cpeGNU/21.12 toolchain.

Let's first check if it has any dependencies that still need to be installed:

```shell
$ eb libdap-3.20.9-cpeGNU-21.12.eb -D
== Temporary log file in case of crash /run/user/10012026/easybuild/tmp/eb-wm_bk3j6/easybuild-puyu_559.log
Dry run: printing build status of easyconfigs and dependencies
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-common/buildtools/buildtools-21.12.eb (module: buildtools/21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/cpeGNU/cpeGNU-21.12.eb (module: cpeGNU/21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/zlib/zlib-1.2.11-cpeGNU-21.12.eb (module: zlib/1.2.11-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/libtirpc/libtirpc-1.3.2-cpeGNU-21.12.eb (module: libtirpc/1.3.2-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/Brotli/Brotli-1.0.9-cpeGNU-21.12.eb (module: Brotli/1.0.9-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/ICU/ICU-69.1-cpeGNU-21.12.eb (module: ICU/69.1-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/cURL/cURL-7.78.0-cpeGNU-21.12.eb (module: cURL/7.78.0-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/bzip2/bzip2-1.0.8-cpeGNU-21.12.eb (module: bzip2/1.0.8-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/ncurses/ncurses-6.2-cpeGNU-21.12.eb (module: ncurses/6.2-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/libreadline/libreadline-8.1-cpeGNU-21.12.eb (module: libreadline/8.1-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/gettext/gettext-0.21-cpeGNU-21.12-minimal.eb (module: gettext/0.21-cpeGNU-21.12-minimal)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/PCRE2/PCRE2-10.37-cpeGNU-21.12.eb (module: PCRE2/10.37-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/XZ/XZ-5.2.5-cpeGNU-21.12.eb (module: XZ/5.2.5-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/libxml2/libxml2-2.9.12-cpeGNU-21.12.eb (module: libxml2/2.9.12-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/libxslt/libxslt-1.1.34-cpeGNU-21.12.eb (module: libxslt/1.1.34-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/gettext/gettext-0.21-cpeGNU-21.12.eb (module: gettext/0.21-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/file/file-5.41-cpeGNU-21.12.eb (module: file/5.41-cpeGNU-21.12)
 * [x] /appl/lumi/mgmt/ebrepo_files/LUMI-21.12/LUMI-L/util-linux/util-linux-2.37.1-cpeGNU-21.12.eb (module: util-linux/2.37.1-cpeGNU-21.12)
 * [ ] /pfs/lustrep3/users/kurtlust/LUMI/LUMI-EasyBuild-contrib/easybuild/easyconfigs/l/libdap/libdap-3.20.9-cpeGNU-21.12.eb (module: libdap/3.20.9-cpeGNU-21.12)
== Temporary log file(s) /run/user/10012026/easybuild/tmp/eb-wm_bk3j6/easybuild-puyu_559.log* have been removed.
== Temporary directory /run/user/10012026/easybuild/tmp/eb-wm_bk3j6 has been removed.
``` 

and now install the library:

```shell
$ eb libdap-3.20.9-cpeGNU-21.12.eb
== Temporary log file in case of crash /run/user/10012026/easybuild/tmp/eb-kfphjoi8/easybuild-kcs00ai5.log
== processing EasyBuild easyconfig
/pfs/lustrep3/users/kurtlust/LUMI/LUMI-EasyBuild-contrib/easybuild/easyconfigs/l/libdap/libdap-3.20.9-cpeGNU-21.12.eb
== building and installing libdap/3.20.9-cpeGNU-21.12...
== fetching files...
== ... (took 2 secs)
== creating build dir, resetting environment...
== unpacking...
== patching...
== preparing...
== ... (took 6 secs)
== configuring...
== ... (took 1 min 6 secs)
== building...
== ... (took 53 secs)
== testing...
== installing...
== ... (took 5 secs)
== taking care of extensions...
== restore after iterating...
== postprocessing...
== sanity checking...
== ... (took 3 secs)
== cleaning up...
== creating module...
== ... (took 2 secs)
== permissions...
== packaging...
== COMPLETED: Installation ended successfully (took 2 mins 20 secs)
== Results of the build can be found in the log file(s)
/users/kurtlust/LUMI-user-appl/SW/LUMI-21.12/L/libdap/3.20.9-cpeGNU-21.12/easybuild/easybuild-libdap-3.20.9-20220329.154535.log
== Build succeeded for 1 out of 1
== Temporary log file(s) /run/user/10012026/easybuild/tmp/eb-kfphjoi8/easybuild-kcs00ai5.log* have been removed.
== Temporary directory /run/user/10012026/easybuild/tmp/eb-kfphjoi8 has been removed.
```

That was... easy. Is that really all there is to it? Well, almost...

### Enabling dependency resolution

The libdap installation worked like a charm, but remember that all required dependencies were already
available (see [above](#dry-run)).

If we try this with the `SAMtools-1.14-cpeGNU-21.12.eb`, for which the required `HTSlib` dependencies is not available yet, it's less successful:

```shell
$ eb SAMtools-1.14-cpeGNU-21.12.eb -M

2 out of 11 required modules missing:

* HTSlib/1.14-cpeGNU-21.12 (HTSlib-1.14-cpeGNU-21.12.eb)
* SAMtools/1.14-cpeGNU-21.12 (SAMtools-1.14-cpeGNU-21.12.eb)
```

```shell
$ eb SAMtools-1.14-cpeGNU-21.12.eb
...
== preparing...
== FAILED: Installation ended unsuccessfully (build directory: /run/user/10012026/easybuild/build/SAMtools/1.14/cpeGNU-21.12): build failed
(first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.14-cpeGNU-21.12 (took 3 secs)
== Results of the build can be found in the log file(s)
/run/user/10012026/easybuild/tmp/eb-rgj1v43y/easybuild-SAMtools-1.14-20220329.155911.ZtDcX.log

ERROR: Build of /appl/lumi/LUMI-EasyBuild-contrib/easybuild/easyconfigs/s/SAMtools/SAMtools-1.14-cpeGNU-21.12.eb failed (err: 'build failed (first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.14-cpeGNU-21.12')
```

Oh my, what's this all about?

If we filter the output a bit and focus on the actual error, the problem is clear:

```
Missing modules for dependencies (use --robot?): HTSlib/1.14-cpeGNU-21.12')
```

The required dependency `HTSlib/1.14-cpeGNU-21.12` is not installed yet,
and EasyBuild does not automatically install missing dependencies unless it is told to do so
(which we didn't do in the configuration for LUMI).

It helpfully suggests to use the `--robot` (or '-r') command line option, so let's try that:

```shell
$ eb SAMtools-1.14-cpeGNU-21.12.eb --robot
...
== resolving dependencies ...
...
== building and installing HTSlib/1.14-cpeGNU-21.12...
...
== COMPLETED: Installation ended successfully (took 13 sec)
...
== building and installing SAMtools/1.14-cpeGNU-21.12...
...
== COMPLETED: Installation ended successfully (took 8 sec)
...
== Build succeeded for 2 out of 2
```

With dependency resolution enabled the `HTSlib` module gets installed first,
before EasyBuild proceeds with installing `SAMtools`. Great!

---

### Trace output

As you may have noticed if you tried the previous example hands-on,
some installations take a while.
An installation can be spending quite a bit of time during the build step, but what is actually going on there?

To provide some more feedback as the installation progresses, you can enable the "`trace`" configuration setting.
Let's do this by defining the `$EASYBUILD_TRACE` environment variable, just to avoid having to type `--trace`
over and over again.

We will redo the installation of `SAMtools-1.14-cpeGNU-21.12.eb` by passing the `--rebuild`
option to the `eb` command (try yourself what happens if you don't use the `--rebuild` option!):

```shell
$ export EASYBUILD_TRACE=1
$ eb SAMtools-1.14-cpeGNU-21.12.eb --rebuild
...
== configuring...
  >> running command:
        [started at: 2022-03-29 18:46:31]
        [working dir: /run/user/10012026/easybuild/build/SAMtools/1.14/cpeGNU-21.12/samtools-1.14]
        [output logged in /run/user/10012026/easybuild/tmp/eb-8p617dr7/easybuild-run_cmd-g7vd83qv.log]
        /users/kurtlust/LUMI-user-appl/sources/generic/eb_v4.5.3/ConfigureMake/config.guess
  >> command completed: exit 0, ran in < 1s
  >> running command:
        [started at: 2022-03-29 18:46:31]
        [working dir: /run/user/10012026/easybuild/build/SAMtools/1.14/cpeGNU-21.12/samtools-1.14]
        [output logged in /run/user/10012026/easybuild/tmp/eb-8p617dr7/easybuild-run_cmd-k0etfv8i.log]
        ./configure --prefix=/users/kurtlust/LUMI-user-appl/SW/LUMI-21.12/L/SAMtools/1.14-cpeGNU-21.12  --build=x86_64-pc-linux-gnu
--host=x86_64-pc-linux-gnu --with-htslib=$EBROOTHTSLIB
  >> command completed: exit 0, ran in 00h00m03s
== ... (took 3 secs)
== building...
  >> running command:
        [started at: 2022-03-29 18:46:34]
        [working dir: /run/user/10012026/easybuild/build/SAMtools/1.14/cpeGNU-21.12/samtools-1.14]
        [output logged in /run/user/10012026/easybuild/tmp/eb-8p617dr7/easybuild-run_cmd-svcps0yj.log]
        make  -j 256  CC="cc"  CXX="CC"  CFLAGS="-O2 -ftree-vectorize -fno-math-errno -fPIC"  CXXFLAGS="-O2 -ftree-vectorize -fno-math-errno
-fPIC"
  >> command completed: exit 0, ran in 00h00m06s
== ... (took 6 secs)
```

That's a bit more comforting to stare at...

SAMtools uses a custom easyblock that is derived from the generic `ConfigureMake` easyblock.
During the *configure* step, the `./configure` command is run with `--build` and `--host` 
options added by the generic ConfigureMake easyblock (and the other command, `config.guess` plays
a role in determining the value of those flags). The `--with-htslib=$EBROOTHTSLIB` flag is added
via our easyconfig file to tell SAMtools to use an already available version of HTSlib rather
than the built-in one.

During the *build* step, the software is actually being compiled
by running the `make` command. EasyBuild automatically uses the available cores on the system (in this case 256).

We even get a pointer to a log file that contains the output of the command being run,
so we can use `tail -f` to see in detail how it progresses.

Once the `make` command completes, we get a message that the command completed with a exit code 0
(implying success), and that it took 3 seconds to run. That's good to know.

Later during the installation, we now also see this output during the sanity check step:

```
== sanity checking...
  >> file 'bin/blast2sam.pl' found: OK
  >> file 'bin/bowtie2sam.pl' found: OK
  >> file 'bin/export2sam.pl' found: OK
  >> file 'bin/interpolate_sam.pl' found: OK
...
  >> loading modules: SAMtools/1.14-cpeGNU-21.12...
  >> running command 'samtools version' ...
  >> result for command 'samtools version': OK
```

Thanks to enabling trace mode, EasyBuild tells us which files (& directories, but there are non in this case)
it is checking for
in the installation, and which command it is trying to run before declaring it a success. Nice!

The extra output you get when trace mode is enabled is concise and hence not overwhelming,
while it gives a better insight into what is going on during the installation.
It may also help to spot unexpected actions being taken during the installation early on,
so you can interrupt the installation before it completes, if deemed necessary.

---

## Using installed software

So far, we have already installed 4 different software packages (SAMtools, HTSlib, libdap);
we even installed SAMtools twice!

A lot was going on underneath the covers: locating and unpacking
the source tarballs, setting up the build environment, configuring the build, compiling,
creating and populating the installation directory, performing a quick sanity check on the installation,
cleaning things up, and finally generating the environment module file corresponding to the installation.

That's great, but how do we now actually *use* these installations?

This is where the generated module files come into play: they form the access portal to the software
installations, and we'll use the ubiquitous `module` command to digest them.

First, we need to make sure that the modules tool is aware of where the module files for
our installations are located. On LUMI, when using the EasyBuild-user module to configure EasyBuild,
everything is taken care of for you and the LUMI modules will also automatically add the
suitable module directories for user-installed software to the search path for modules.
By default, EasyBuild-config will install in `$HOME/EasyBuild`, but it is possible to
build the installation in a different directory by pointing to it with the environment
variable `EBU_USER_PREFIX`. Of course this variable needs to be set before loading the `LUMI`
module. (Note that one reason why we don't load a software stack by default is that in
the current setup of LUMI this module would be loaded before the user gets the chance to set
that environment variable in `.bash_profile` or `.bashrc`.)

When loading the `EasyBuild-user` module, the module command will show you were EasyBuild
will install the software and put the modules, and also put its repository of
processed easyconfig file. 

```shell
ml EasyBuild-user

EasyBuild configured to install software from the LUMI/21.12 software stack for the LUMI/L
partition in the user tree at /users/kurtlust/LUMI-user-appl.
  * Software installation directory: /users/kurtlust/LUMI-user-appl/SW/LUMI-21.12/L
  * Modules installation directory: /users/kurtlust/LUMI-user-appl/modules/LUMI/21.12/partition/L
  * Repository: /users/kurtlust/LUMI-user-appl/ebrepo_files/LUMI-21.12/LUMI-L
  * Work directory for builds and logs: /run/user/10012026/easybuild
    Clear work directory with clear-eb
```

EasyBuild will copy each easyconfig file it installs to
the repository and add some lines to it with information about the installation. It 
also has some options that may edit the source easyconfig, e.g., when asking EasyBuild
to try to build with another toolchain.

You can always check where EasyBuild is installing stuff by checking the output of
`eb --show-config`.

If you're unsure where EasyBuild is installing stuff at this point,
check the output of `eb --show-config`; the value of the `installpath` configuration setting is what we are interested in now:

```shell
$ eb --show-config
...
buildpath             (E) = /run/user/XXXXXXXX/easybuild/build
...
installpath-modules   (E) = /users/XXXXXXXX/LUMI-user/modules/LUMI/21.12/partition/L
installpath-software  (E) = /users/XXXXXXXX/LUMI-user/SW/LUMI-21.12/L...
...
repositorypath        (E) = /users/XXXXXXXX/LUMI-user/ebrepo_files/LUMI-21.12/LUMI-L
...
sourcepath            (E) = /users/XXXXXXXX/LUMI-user/sources:/appl/lumi/sources/easybuild
...
```

This is slightly different from the default EasyBuild setup, where the modules, software,
repository and sources would be installed in respectively the subdirectories `modules`,
`software`, `ebfiles_repo` and `sources` of the directory pointed to by the `installpath` 
line. 

The modules directory is also a simplified one from the standard EasyBuild one as that also
provides a module categorisation besides a directory containing all modules. As this categorisation
is largely arbitrary and hard to use in the module system, we decided simply not to use it in
our installation and use a custom naming scheme. 

However, if you would be using EasyBuild on another system with its default configuration, the
above setup would be used. For more information, we refer to the generic EasyBuild tutorials on the
[EasyBuild tutorial site](https://easybuilders.github.io/easybuild-tutorial/).

Now the modules tool should be aware of our brand new installations:

```shell
$ module avail
...
-- EasyBuild managed user software for software stack LUMI/21.12 on LUMI-L ---
   HTSlib/1.14-cpeGNU-21.12      libdap/3.20.9-cpeGNU-21.12
   SAMtools/1.14-cpeGNU-21.12

----- EasyBuild managed software for software stack LUMI/21.12 on LUMI-L -----
...
```

This output shows both the modules for our own installations as well as the "central" installations
(which we omitted for brevity).

Now we can load these modules and start using these software installations.

Let's test this for SAMtools. In our current environment, the `samtools` command is not available yet:

```shell
$ module list

Currently Loaded Modules:
  1) perftools-base/21.12.0
  2) cce/13.0.0
  3) craype/2.7.13
  4) cray-dsmml/0.2.2
  5) cray-mpich/8.1.12
  6) cray-libsci/21.08.1.2
  7) PrgEnv-cray/8.2.0
  8) ModuleLabel/label                     (S)
  9) init-lumi/0.1                         (S)
 10) craype-x86-rome
 11) craype-accel-host
 12) libfabric/1.11.0.4.106
 13) craype-network-ofi
 14) xpmem/2.2.40-2.1_3.9__g3cf3325.shasta
 15) partition/L                           (S)
 16) LUMI/21.12                            (S)

  Where:
   S:  Module is Sticky, requires --force to unload or purge
$ samtools
-bash: samtools: command not found
```

Loading the module for SAMtools changes that:

```shell
$ module load SAMtools/1.14-cpeGNU-21.12

Lmod is automatically replacing "cce/13.0.0" with "gcc/11.2.0".
Lmod is automatically replacing "PrgEnv-cray/8.2.0" with "cpeGNU/21.12".

Due to MODULEPATH changes, the following have been reloaded:
  1) cray-mpich/8.1.12

$ module list

Currently Loaded Modules:
  1) perftools-base/21.12.0
  2) ModuleLabel/label                     (S)
  3) init-lumi/0.1                         (S)
  4) craype-x86-rome
  5) craype-accel-host
  6) libfabric/1.11.0.4.106
  7) craype-network-ofi
  8) xpmem/2.2.40-2.1_3.9__g3cf3325.shasta
  9) partition/L                           (S)
 10) LUMI/21.12                            (S)
 11) gcc/11.2.0
 12) craype/2.7.13
 13) cray-mpich/8.1.12
 14) cray-libsci/21.08.1.2
 15) cray-dsmml/0.2.2
 16) cpeGNU/21.12
 17) ncurses/6.2-cpeGNU-21.12
 18) zlib/1.2.11-cpeGNU-21.12
 19) bzip2/1.0.8-cpeGNU-21.12
 20) gettext/0.21-cpeGNU-21.12-minimal
 21) XZ/5.2.5-cpeGNU-21.12
 22) Brotli/1.0.9-cpeGNU-21.12
 23) cURL/7.78.0-cpeGNU-21.12
 24) HTSlib/1.14-cpeGNU-21.12
 25) SAMtools/1.14-cpeGNU-21.12

  Where:
   S:  Module is Sticky, requires --force to unload or purge

$ samtools --version
samtools 1.14
Using htslib 1.14
Copyright (C) 2021 Genome Research Ltd....
...
```

Note that the modules for the required dependencies, including the compiler toolchain (which provides runtime libraries
like `libstdc++.so`), are loaded automatically. The "`module load`" command changes the active environment,
by updating environment variables like `$PATH` for example, to make the software available for use.

##### Resetting your environment

To restore your environment to a pristine state in which no modules are loaded, you can either
unload the loaded modules one by one using "`module unload`", or you can unload all of them at once using
"`module purge`". On LUMI, `module purge` will unload all application modules but will not undo the selection
of the software stack. It will reset the software stack though to use those modules that fit best
with the hardware of the current node (i.e., you may find a different `partition` module).

```shell
$ module purge
The following modules were not unloaded:
  (Use "module --force purge" to unload all):

  1) LUMI/21.12               6) xpmem/2.2.40-2.1_3.9__g3cf3325.shasta
  2) craype-x86-rome          7) partition/L
  3) craype-accel-host        8) init-lumi/0.1
  4) libfabric/1.11.0.4.106   9) ModuleLabel/label
  5) craype-network-ofi
$ module list

Currently Loaded Modules:
  1) LUMI/21.12                            (S)
  2) craype-x86-rome
  3) craype-accel-host
  4) libfabric/1.11.0.4.106
  5) craype-network-ofi
  6) xpmem/2.2.40-2.1_3.9__g3cf3325.shasta
  7) partition/L                           (S)
  8) init-lumi/0.1                         (S)
  9) ModuleLabel/label                     (S)

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```

Running `module --force purge` instead will remove all modules, including the `init-lumi` 
module which does part of the initialisation. You will not be able to use the software
stacks completely as before without first loading `init-lumi` in its most recent (or default)
version again!

```shell
$ module --force purge
$ module list
No modules loaded
```

---

## Stacking software

Maybe you have overlooked how the software we are playing around with was not only installed across multiple
different installation directories per software, we are also "stacking" our own installations (in `$HOME/EasyBuild`
or `$EBU_USER_PREFIX`) on top of installations that are provided in a totally different location (`/appl/lumi`).

**EasyBuild doesn't care *where* software is installed: as long as the module file that provides access to it
is available, it is happy to pick it up and use it when required.**

This implies that end users of LUMI can easily install their
own small software stack on top of what is provided centrally by the LUMI User Support,
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

---

*[[next: Troubleshooting]](../2_Using/2_01_troubleshooting.md)*
