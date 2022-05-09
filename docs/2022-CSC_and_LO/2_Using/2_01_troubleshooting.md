# Troubleshooting

*[[back: Basic usage]](../1_Intro/1_08_basic_usage.md)*

---

Whatever tool you use, when installing scientific software you'll
be running into problems rather sooner than later.

In this part we take a look at how you can **troubleshoot a failing installation**,
and focus on a couple of EasyBuild aspects that can be helpful in that context,
like the **error messages produced by EasyBuild**, the detailed **log file** that is
available for the installation and the **build directory** where most software is
being compiled before it actually gets installed.

At the end of this part an exercise is available in which you get
to fix a failing installation, so pay attention!

## EasyBuild error messages

When EasyBuild detects that something went wrong, it will usually produce a
short (and hopefully helpful) error message.

Things that could go wrong during an installation include:

* missing source or patch files;
* a checksum error on a downloaded source or patch file;
* required dependencies that are not specified in the easyconfig file;
* failing shell commands;
* running out of available memory or disk space;
* compiler errors and compiler crashes ;
* a segmentation fault caused by a flipped bit triggered by a cosmic ray 
  ([really, it happens!](https://blogs.oracle.com/linux/post/attack-of-the-cosmic-rays));

Unfortunately this is not an exhaustive list, there are plenty of other
potential problems that could result in a failing installation...

For each of the shell commands that EasyBuild executes during an
installation, it will check the exit status.
If the exit status is zero, EasyBuild will usually assume that the shell command
ran correctly, and it will continue with the rest of the installation procedure.
If the exit status is anything but zero, EasyBuild will assume that a problem
has occurred, and the installation will be interrupted.

### Example

Here is an example of an EasyBuild error message (slightly reformatted for clarity):

```
$ eb example.eb
...
== building...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/example/1.0/GCC-10.2.0):
build failed (first 300 chars): cmd "make" exited with exit code 2 and output:
/usr/bin/g++ -O2 -ftree-vectorize -march=znver2 -fno-math-errno -c -o core.o core.cpp
cc1plus: error: bad value (‘znver2’) for ‘-march=’ switch (took 1 sec)
== Results of the build can be found in the log file(s) /tmp/eb-dbobppfh/easybuild-example-1.0-20200613.145414.aUEJA.log
ERROR: Build of /home/easybuild/subread.eb failed (err: ...)
```

Let's break this down a bit: during the `build` step of the installation
procedure EasyBuild was running `make` as a shell command, which
failed (exit code 2, so not zero).
The `make` command tripped over the compilation of `core.cpp` that failed because
`-march=znver2` is not a known option to the `g++` command.

OK fine, but now what? Can you spot something suspicious here?
Wait a minute... Why is `make` using `/usr/bin/g++` for the compilation?!
That's not where our toolchain compiler is installed,
that's somewhere under `/opt/cray/pe/gcc`.

Let's see what `/usr/bin/g++` is:

```
$ /usr/bin/g++ --version
g++ (SUSE Linux) 7.5.0
```

Oh my that's an ancient compiler (7.5 was released on November 14, 2019,
a few months after the release of the Zen2 architecture, but
the base version, 7.1, is really from May 2, 2017, long before the Zen2 architecture was around)
That could definitely explain why it doesn't know about the Zen2 architecture yet...

Your next step in this case should probably be figuring
out why `/usr/bin/g++` is being used rather than just `g++`, which would
result in using the right compiler version because EasyBuild sets up the build
environment carefully.

This is a fictitious example of course, but hopefully it gives you a feeling
of how errors that occur during the installation are handled.

## EasyBuild log files

Finding the cause of a problem that made the installation fail is, unfortunately, not always that straightforward...

EasyBuild includes the first 300 characters of the output produced by a failing
shell command in the error message, which is a simple way to try include
actionable information in the error message while not flooding your terminal
with the full output of the command that failed.

In some cases there won't be any useful information in there however,
since the actual error message(s) could only appear way later, perhaps even after
the command was already running for several minutes.

In that case, you will have to dive into the log file that is created by EasyBuild for
every installation, which is located in the unique temporary directory for the EasyBuild session.

See for example this output line from our earlier example error message:

```
== Results of the build can be found in the log file(s) /tmp/eb-dbobppfh/easybuild-example-1.0-20200613.145414.aUEJA.log
```

You can open this file with your favorite text editor or a tool like `less`
to take a look at the information collected in the log file, which includes
things like:

* informative messages produced by both the EasyBuild framework and the easyblock
  describing how the installation is progressing;
* how the build environment was set up: which modules were loaded, which environment variables were set;
* the exact shell commands that were executed, and in which directory they were run;
* the full output produced by these commands, and their exit code;

Note that the installation log is also copied into each software installation
directory for successful installation, into the `easybuild` subdirectory.
For example:

```
/appl/lumi/SW/LUMI-21.12/L/EB/ncurses/6.2-cpeGNU-21.12/easybuild/easybuild-ncurses-6.2-20220302.110244.log
```

### Last log

The `eb` command supports a handy little option that prints the location
to the most recently updated build log. You can leverage this to quickly
open the build log of the last ***failed*** EasyBuild session in an editor:

```
vim $(eb --last-log)
```

### Navigating log files

Usually you want to go to the end of the log file and then work your way up,
either by scrolling or by searching for specific patterns. Here are a couple
of suggestions of patterns you can use to locate errors:

* `ERROR`
* `Error 1`
* `error: `
* `failure`
* `not found`
* `No such file or directory`
* `bazel`
* `Segmentation fault`

Using "`error`" as a search pattern is not very useful: you will hit a lot of log lines
that are not actually errors at all (like the compilation of an `error.c` file),
and you'll miss others that do include errors but mention `ERROR` or `Error`
rather than `error`.

When using `less` to view a log file, you can navigate it by:

* hitting '`$`' followed by '`G`' to go to the end of the log file;
* using your arrow keys to scroll up/down;
* typing '`?`' followed by some text and Enter to search backwards for a particular
pattern ('`/`' to search forwards, '`n`' for next match);
* hitting '`q`' to exit;

It can also be helpful to zoom in on a specific step of the installation procedure,
which you can do by looking for step markers like these:

```
== 2020-06-13 01:34:48,816 example INFO configuring...
== 2020-06-13 01:34:48,817 example INFO Starting configure step
...
== 2020-06-13 01:34:48,823 main.EB_HPL INFO Running method configure_step part of step configure
```

If you want to look at the start of the output produced by a particular command,
you can look for the log message that looks like this (this is from the installation
log for `HDF5`):

```
== 2020-06-09 13:11:19,968 run.py:222 INFO running cmd:  make install
== 2020-06-09 13:11:25,186 run.py:538 INFO cmd " make install " exited with exit code 0 and output:
Making install in src
make[1]: Entering directory `/tmp/example/HDF5/1.10.7/gompi-2020b/hdf5-1.10.7/src'
...
```

It can be useful to look for the *first* error that occurred in the output of a command, since subsequent errors are
often fallout from earlier errors. You can do this by first navigating
to the start of the output for a command using "`INFO running cmd`" as a search pattern, and then looking for patterns
like "`error:`" from there.

## Inspecting the build directory

When an installation fails the corresponding build directory is *not* cleaned up
automatically, that is only done for successful installations.
This allows you to dive in and check for clues in the files that are stored there.

The location of the build directory is mentioned in the EasyBuild error message:

```
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/example/1.0/GCC-10.2.0): ...
```

For software using a classic `configure` script, you may have to locate
and inspect the `config.log` file in the build directory to determine the underlying cause of an error. For software using CMake as a configuration tool you often have to check in
`CMakeOutput.log` or `CMakeError.log` for clues, which are sneakily hidden by CMake in a `CMakeFiles` subdirectory of the build directory.

As a side note here: as EasyBuild does not clean out old and failed builds you will need to eventually manually remove these build directories from the `buildpath` directory. On the login nodes of LUMI this is currently not much of an issue as `$XDG_RUNTIME_DIR` is (ab)used for build and
temporary files and that directory is cleaned automatically. However, when building on compute nodes, where `$XDG_RUNTIME_DIR` is
not available, it is essential to manually clean that directory as the space is not automatically cleaned when your session
ends. The `EasyBuild-user` module does define the bash function `clear-eb` that can be used to clear that space.

## Exercise

Let's work our way through a less smooth software installation,
using the easyconfig file that is provided below.

Don't worry if most of this is still unclear to you, we'll get
to writing easyconfig files from scratch [later in this tutorial](../2_02_creating_easyconfig_files).

```python
easyblock = 'MakeCp'

name = 'Subread'
version = '2.0.1'

homepage = 'http://subread.sourceforge.net'
description = "High performance read alignment, quantification and mutation discovery"

toolchain = {'name': 'PrgEnv-gnu', 'version': '21.10'}

# download from https://download.sourceforge.net/subread/subread-2.0.1-source.tar.gz
sources = ['subread-%(version)s-source.tar.gz']
checksums = ['d808eb5b1823c572cb45a97c95a3c5acb3d8e29aa47ec74e3ca1eb345787c17b']

start_dir = 'src'

# -fcommon is required to compile Subread 2.0.1 with GCC 10/11,
# which uses -fno-common by default (see https://www.gnu.org/software/gcc/gcc-10/porting_to.html)
buildopts = '-f Makefile.Linux CFLAGS="-fast -fcommon"'

files_to_copy = ['bin']

sanity_check_paths = {
    'files': ['bin/featureCounts', 'bin/subread-align'],
    'dirs': ['bin/utilities'],
}

sanity_check_commands = ["featureCounts --version"]

moduleclass = 'bio'
```

Do you spot any potential problems yet with this easyconfig file?

***Preparation***

Start by copying the text above in a file named `subread.eb`
(which does not follow the EasyBuild conventions but that is not a problem for this exercise),
so you can gradually fix the problem you'll encounter.

Also make sure that the pre-installed software stack is available,
and that the EasyBuild-user module is loaded (unless you installed EasyBuild
yourself):

```
module load LUMI/21.12
module load EasyBuild-user
```

This will configure EasyBuild correctly for this exercise, though if you already have 
an existing EasyBuild user installation you may want to work in a different one
by pointing `$EBU_USER_PREFIX` to the desired work directory before loading 
`LUMI/21.12`.

Check your configuration via `eb --show-config`.

Strictly speaking the configuration doesn't matter much for the sake of this
exercise, but it may help with the step-wise approach we'll take and
grasping the solutions.

Remember though: *no peeking* before you tried to solve each step yourself!

---

***Exercise T.1**** - Toolchain*

Try to install the `subread.eb` easyconfig file, see what happens.

Take into account that we just want to get this software package installed,
we don't care too much about details like the version of the dependencies or
the toolchain here...


??? success "(click to show solution)"

    The installation fails because the easyconfig specifies that `PrgEnv-gnu/21.10`
    should be used as toolchain:

    ```
    $ eb subread.eb
    ...
    ERROR: Failed to process easyconfig /pfs/lustrep3/users/kurtlust/easybuild-tutorial/Troubleshooting/subread.eb: Toolchain PrgEnv-gnu not found, 
    available toolchains: ...
    ...
    ```

    `PrgEnv-gnu` is an HPE Cray PE module that may look like a toolchain - it certainly has 
    the same function: provide compiler, MPI and basic math libraries - but it is not 
    recognised as a toolchain by EasyBuild. EasyBuild prefers to manage its own modules so that it knows
    well what is in it which is not the case with the `PrgEnv-*` modules from the Cray PE
    as the content may differ between systems and as the versions of the compilers etc. that
    are loaded differ on other modules that are loaded. Hence we created Cray-specific toolchains.
    You'll actually find two series of Cray toolchains in the list of available toolchains. 
    
    A more readable list of toolchains supported by EasyBuild can be generated using

    ```shell
    eb --list-toolchains
    ```
    
    The `CrayGNU`, `CrayIntel`, `CrayPGI` and `CrayCCE` are included with the EasyBuild distribution
    and where developed by CSCS for their systems using Environment Modules. These were not compatible
    with the initial releases of the Cray PE with Lmod modules so new ones were developed on which we
    also built for the LUMI toolchains. Those are called `cpeCray`, `cpeGNU`, `cpeAOCC` and `cpeAMD`
    and are maintained by LUST and available via the LUMI repositories.

Note: Depending on how you use EasyBuild you may now first run into the problem of Exercise T.2 or 
first run into the problem covered by Exercise T.3.


---

***Exercise T.2**** - Sources*

After fixing the problem with the name of the toolchain, try running `eb` again.

What's wrong now? How can you fix it quickly?

Can you fix the problem you run into, perhaps without even changing
the easyconfig file?

??? success "(click to show solution)"

    The installation fails because the source file `subread-2.0.1-source.tar.gz`
    is not found:
    ```
    $ eb subread.eb
    ...
    == FAILED: Installation ended unsuccessfully (build directory: /run/user/XXXXXXXX/easybuild/build/Subread/2.0.1/cpeGNU-21.12): build failed (first 300 chars):
    Couldn't find file subread-2.0.1-source.tar.gz anywhere, and downloading it didn't work either...
    Paths attempted (in order): ...
    ```

    In this case, the problem is that the easyconfig file does not specify
    where the sources can be downloaded from. Not automatically at least,
    but there is a helpful comment included:
    ```python
    # download from https://download.sourceforge.net/subread/subread-2.0.1-source.tar.gz
    sources = ['subread-%(version)s-source.tar.gz']
    ```

    We can download the source tarball ourselves,
    and move it to the location where EasyBuild expects to find it
    (in the `sourcepath` directory):
    ```
    curl -OL https://download.sourceforge.net/subread/subread-2.0.1-source.tar.gz
    mkdir -p $EBU_USER_PREFIX/sources/s/Subread
    mv subread-2.0.1-source.tar.gz $EBU_USER_PREFIX/sources/s/Subread/
    ```

    (assuming you have set `EBU_USER_PREFIX`, otherwise replace `$EBU_USER_PREFIX` with
    `$HOME/EasyBuild`).

    Or, we can change the easyconfig file to specify the location where
    the easyconfig file can be downloaded from:
    ```python
    source_urls = ['https://download.sourceforge.net/subread/']
    sources = ['subread-%(version)s-source.tar.gz']
    ```
    Note that the `source_urls` value is a *list* of candidate download URLs,
    *without* the filename of the source file itself.

    This way, EasyBuild will download the source file when running `eb subread.eb`.

    The source tarball is fairly large (23MB), so don't be alarmed if the download takes a little while.

    ```shell
    $ ls -lh $EBU_USER_PREFIX/sources/s/Subread
    total 23M
    -rw-rw-r-- 1 XXXXXXXX XXXXXXXX 23M Mar 30 16:08 subread-2.0.1-source.tar.gz
    ```

---

***Exercise T.3**** - Toolchain revisited*

After fixing the problem with missing source file, try the installation again.

What's wrong now? How can you fix it quickly?

Take into account that we just want to get this software package installed,
we don't care too much about details like the version of the dependencies or
the toolchain here...


??? success "(click to show solution)"

    The installation fails because the easyconfig specifies that `PrgEnv-gnu/21.12`
    should be used as toolchain:

    ```shell
    $ eb subread.eb
    ...
    ERROR: Build of /pfs/lustrep3/users/kurtlust/easybuild-tutorial/Troubleshooting/subread.eb failed (err: 'build failed (first 300 chars): 
    No module found for toolchain: cpeGNU/21.10')
    ...
    ```

    We don't have this `cpeGNU` version installed, but we do have `cpeGNU/21.12`:

    ```shell
    $ module avail cpeGNU/
    ----- Infrastructure modules for the software stack LUMI/21.12 on LUMI-L -----
       cpeGNU/21.12
    ...
    ```

    So let's try using that instead.

    Edit the easyconfig file so it contains this:

    ```python
    toolchain = {'name': 'cpeGNU', 'version': '21.12'}
    ```

---

***Exercise T.4**** - Build step*

With the first three problems fixed, now we can actually try to build the software.

Can you fix the next problem you run into?

??? success "(click to show solution)"

    The compilation fails, but the error message we see is incomplete due to
    EasyBuild truncating the command output (only the 300 first characters of the output are shown):
    ```
    == FAILED: Installation ended unsuccessfully (build directory: /run/user/10012026/easybuild/build/Subread/2.0.1/cpeGNU-21.12): build failed
    (first 300 chars): cmd " make  -j 256 -f Makefile.Linux CFLAGS="-fast -fcommon"" exited with exit code 2 and output:
    gcc  -mtune=core2  -O3 -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\""2.0.1"\"  -D_FILE_OFFSET_BITS=64    -fmessage-length=0
    -ggdb  -fast -fcommon -I/opt/cray/pe/libsci/21.08.1.2/GNU/9.1/x86 (took 4 secs)
    ```

    If you open the log file (e.g., with `view $(eb --last-log)`) and scroll to the end,
    the error is pretty obvious:
    ```
    gcc: error: unrecognized command line option -fast; did you mean -Ofast?
    make: *** [core.o] Error 1
    ```

    The easyconfig file hard specifies the `-fast` compiler flag via the `CFLAGS` argument to the build command:
    ```python
    # -fcommon is required to compile Subread 2.0.1 with GCC 10,
    # which uses -fno-common by default (see https://www.gnu.org/software/gcc/gcc-10/porting_to.html)
    buildopts = '-f Makefile.Linux CFLAGS="-fast -fcommon"'
    ```

    EasyBuild sets up the build environment, so there should be no need
    to hard specify compiler flags (certainly not incorrect ones).
    The comment above the `buildopts` definition makes it clear that the `-fcommon`
    flag *is* required though, because GCC 10 became a bit stricter by
    using `-fno-common` by default (and we're using GCC 11 in `cpeGNU/21.12`). 
    Note that we are using `-fcommon`
    as an escape mechanism here: it would be better to fix the source code
    and create a patch file instead.

    An easy way to fix this problem is to replace the `-fast` with `-Ofast`,
    as the compiler error suggests.

    In this case it is advised to change the `CFLAGS` argument that is added
    to be build command to replace the `-fast` with `$CFLAGS`,
    which is defined in the build environment by EasyBuild.

    ```python
    buildopts = '-f Makefile.Linux CFLAGS="$CFLAGS -fcommon"'
    ```

    Note that we need to be careful with quotes here: we use inner double quotes
    to ensure that `$CFLAGS` will be expanded to its value when the build command is run.
    As you can see after the change by doing a dry-run:

    ```
    $ eb subread.eb -x
    ...

    Defining build environment...

      export BLAS_INC_DIR='/opt/cray/pe/libsci/21.08.1.2/GNU/9.1/x86_64/include'
    ...
      export CC='cc'
      export CFLAGS='-O2 -ftree-vectorize -fno-math-errno'
    ...
    [build_step method]
      running command "make  -j 256 -f Makefile.Linux CFLAGS="$CFLAGS -fcommon""
      (in /run/user/10012026/easybuild/build/Subread/2.0.1/cpeGNU-21.12/Subread-2.0.1/src)
    ...
    ```  

    EasyBuild will launch the command 
    ```
    make  -j 256 -f Makefile.Linux CFLAGS="$CFLAGS -fcommon"
    ```
    in a shell where `CFLAGS` is defined and set to an appropriate value (determined by
    defaults in EasyBuild, settings in the EasyBuild configuration and settings in the
    easyconfig file that we shall discuss later).


---

***Exercise T.5**** - Sanity check*

After fixing the compilation issue, you're really close to getting the installation working, we promise!

Don't give up now, try one last time and fix the last problem that occurs...

??? success "(click to show solution)"

    Now the installation itself works but the sanity check fails,
    and hence the module file does not get generated:
    ```
    $ eb subread.eb
    ...
    == FAILED: Installation ended unsuccessfully (build directory: /run/user/10012026/easybuild/build/Subread/2.0.1/cpeGNU-21.12): 
    build failed (first 300 chars): Sanity check failed: sanity check command featureCounts --version exited with code 255 
    (output: featureCounts: unrecognized option '--version'
    ...
    ...
    ```

    If you look at the full output in the log file you can see
    that the correct option to check the version of the `featureCounts` command
    is "`-v`" rather than "`--version`", so we need to fix this in the easyconfig file.

    Make the following change in the easyconfig file:
    ```python
    sanity_check_commands = ["featureCounts -v"]
    ```

    After doing so, **you don't have to redo the installation
    from scratch**, you can use the `--module-only` option to only run the
    sanity check and generate the module file again:
    ```
    eb subread.eb --module-only
    ```

---

---

***Exercise T.6**** - Post-install check of the log file*

In the end, you should be able to install Subread 2.0.1 with the cpeGNU 21.12 toolchain by 
fixing the problems with the `subread.eb` easyconfig file.

Check your work by manually loading the module and checking the version
via the `featureCounts` command, which should look like this:

```shell
$ module load Subread/2.0.1-cpeGNU-21.12
...
$ featureCounts -v
featureCounts v2.0.1
```

So all is well know, or is it?

Unfortunately we don't have a complete log file of the last build (at least if you only re-installed
the module) as most of the steps were skipped in the last build.

Let's do the build again and check the full log file, just to be sure. But we'll first need to
clean up a bit as EasyBuild doesn't like to build in a shell in which the modules which are
used for the build are already loaded:

```shell
module unload Subread cpeGNU
```

Now look at the output of an extended dry run and then rebuild to have a full log file so
that we can expect if EasyBuild really did what we expected:

```shell
eb subread.eb -x
eb subread.eb -f
```

(the last line to force a rebuild).

Now go to the `$EBU_USER_PREFIX/SW/LUMI-21.12/L/Subread/2.0.1-cpeGNU-21.12/easybuild`
(or `$HOME/EasyBuild/SW/LUMI-21.12/L/Subread/2.0.1-cpeGNU-21.12/easybuild`, depending on your configuration,) directory and open
the log file in your favourite editor. Search for the build step by searching for the string
`INFO Starting build` and look carefully at how the program was actually build...

You'll very likely have to look at the solution to understand how to correct the
problems as that requires more advanced knowlege than we have at this point in
the tutorial, but try to figure out what could be wrong first though...

??? hint "(Click for a hint)"
    Check the compiler that has been used and the compiler flags. Are these really
    what you would like to see and what you would expect from running `eb subread.eb -x`
    as we did before?


??? success "(click to show solution)"
    According to the output of `eb subread.eb -x`, the build should be done using 
    `cc` as the compiler as that is the value assigned to the `CC` environment which
    by convention points to the C compiler. Moreover, EasyBuild sets `CFLAGS` to 
    `-O2 -ftree-vectorize -fno-math-errno`, and then the `make` command line adds
    `-fcommon` to those flags.

    However, this is not what we see in the build log. It turns out that Subread
    is one of those horror packages that follows no established convention for 
    build procedures.
    
    One of the first lines we 
    run into (yours may differ since this is a parallel build) is
    
    ```
    gcc  -mtune=core2  -O3 -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\""2.0.1"\"  -D_FILE_OFFSET_BITS=64    -fmessage-length=0  -ggdb  -O2 -ftree-vectorize -fno-math-errno -fcommon -I/opt/cray/pe/libsci/21.08.1.2/GNU/9.1/x86_64/include  -c -o core.o core.c
    ```

    The flags that we added via `CFLAGS` are in there but only after some other flags.
    The build process didn't pick up our C compiler either! And o horror, it even defines
    the processor architecture! So it will not run on older architectures than the Intel Sandy 
    Bridge family, but it will not exploit newer architectures either (well, it it could, the code
    may not benefit at all from newer vectorisation instructions, but at least the compiler might
    do a better job optimising). 
    Scrolling down a bit we see some lines that generate executables from a single
    C file and a list of already generated object files, and there we don't even see our
    compiler flags at all!

    The problem is truly in the makefiles of Subread. We could now untar the source file
    that was saved by EasyBuild in a temporary work directory and inspect the sources, or we could
    retry the build and stop after the build step. Let's take the latter option. The command to 
    do this is

    ```
    eb subread.eb -f --stop build
    ```

    We'll need to search for the build directory now as it is not printed when EasyBuild stops in
    a regular way.

    ```
    pushd $EASYBUILD_BUILDPATH/Subread/2.0.1/cpeGNU-21.12
    cd subread-2.0.1-source
    cd src
    ```

    The EasyConfig uses the makefile `Makefile.Linux` so let's check that one. Some of the crucial
    lines are:

    ```
    CC_EXEC = gcc
    OPT_LEVEL = 3

    CCFLAGS = -mtune=core2 ${MACOS} -O${OPT_LEVEL} -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\"${SUBREAD_VERSION}\"  -D_FILE_OFFSET_BITS=64 ${WARNING_LEVEL}
    CC = ${CC_EXEC}  ${CCFLAGS}  -fmessage-length=0  -ggdb
    ```

    We see several problems at once

    -   `CC` is defined in the Makefile in a way that we do not want to redefine it on the `make`` command
        line as it also already includes all compiler options. It turns out we need to redefine `CC_EXEC`
        instead to use a different compiler.
    -   `CCFLAGS` includes several options that should enter through `CFLAGS` and should not be imposed in
        a proper build process. The most dangerous one is the `-mtune=core2`, but in general we prefer to 
        leave the choice of the optimisation level to EasyBuild also unless there are good reasons to use
        a very specific optimisation level.
    -   One may wonder why at least some of the compiles did pick up `CFLAGS` then. This is because these
        files were compiled using an implicit rule that used the `CC` command as defined in `Makefile.Linux`
        so with a lot of compiler flags already added to it and then adds `CFLAGS` as defined on the `make`
        command line generated by EasyBuild. Those compile commands that were generated from an explicit rule 
        don't pick up `CFLAGS` though.

    There are two ways to fix this in EasyBuild (besides teaching the developer of this software package how
    to write a proper Makefile following the usual conventions).

    1.  The approach which is usually followed is to make a patch file for `Makefile.Linux` that changes the line
        
        ```
        CCFLAGS = -mtune=core2 ${MACOS} -O${OPT_LEVEL} -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\"${SUBREAD_VERSION}\"  -D_FILE_OFFSET_BITS=64 ${WARNING_LEVEL}
        ``` 

        to, e.g.,

        ```
        CCFLAGS = ${CFLAGS} -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\"${SUBREAD_VERSION}\"  -D_FILE_OFFSET_BITS=64 ${WARNING_LEVEL}
        ``` 

        combined with changing the `buildopts` line to also overwrite `CC_EXEC`:

        ```
        buildopts = '-f Makefile.Linux CC_EXEC="$CC" CFLAGS="-fast -fcommon"'
        ```

        (or you could also change the `CC_EXEC` line in `Makefile.Linux` with the same patch to use the `cc` command,
        but that would also make the patch file Cray-only.) 

    2.  The other option is to simply edit `Makefile.Linux` using `sed` to replace 
        `-mtune=core2 ${MACOS} -O${OPT_LEVEL}` with
        `${CFLAGS}`. This can be done by executing a `sed` command before calling `make`. 
        As we shall see later in this tutorial, this can be done with `prebuildopts`: 

        ```python
        prebuildopts = "sed -e 's/-mtune=core2 ${MACOS} -O${OPT_LEVEL}/${CFLAGS}/' -i Makefile.Linux && "
        ```

        and as in the previous case we also still need to overwrite `CC_EXEC` with the 
        correct compiler on the `make` command line:

        ```
        buildopts = '-f Makefile.Linux CC_EXEC="$CC" CFLAGS="-fast -fcommon"'
        ```

        Now check the output of `eb subread.eb -x` to see what will happen during the build phase.
    
    Let's implement the second approach, then do a full rebuild:

    ```shell
    eb subread.eb -f
    ```

    and then open the log file (again in the `easybuild` subdirectory of the software installation
    directory) and check what happened now during the build step.

    As we scroll through the output of the build step, we still see a few lines mentioning
    `gcc`... It turns out there is a second Makefile hidden in the subdirectory `longread-one` so we 
    need to edit that one too... So following the second approach we can do this with

    ```python
    prebuildopts = "sed -e 's/-mtune=core2 ${MACOS} -O${OPT_LEVEL}/${CFLAGS}/' -i Makefile.Linux && "
    prebuildopts += "sed -e 's/-mtune=core2 ${MACOS} -O${OPT_LEVEL}/${CFLAGS}/' -i longread-one/Makefile && "
    ```

    Now we can build once more and check the log file and finally we can be satisfied...

    This exercise also show how tedious developing an easyconfig can be. And it also shows mistakes that
    are sometimes overlooked in easyconfigs that come with EasyBuild.


---

*[[next: Creating easyconfig files]](2_02_creating_easyconfig_files.md)*
