# Troubleshooting

When installing scientific software you are bound to run into problems 
that make the installation fail sooner or later, even when using EasyBuild.

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
* a segmentation fault caused by a flipped bit triggered by a cosmic ray ([really, it happens!](https://blogs.oracle.com/linux/attack-of-the-cosmic-rays-v2));

Unfortunately this is not an exhaustive list, there are plenty of other
potential problems that could result in a failing installation...

For each of the shell commands that EasyBuild executes during an
installation, it will check the exit status.
If the exit status is zero, EasyBuild will usually assume that the shell command
ran correctly, and it will continue with the rest of the installation procedure.
If the exit status is anything but zero, a problem has occurred and the installation will be interrupted.

### Example

Here is an example of an EasyBuild error message (slightly reformatted for clarity):

```
$ eb trouble.eb
...
== building...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/trouble/1.0/GCC-9.3.0):
build failed (first 300 chars): cmd "make" exited with exit code 2 and output:
/usr/bin/g++ -O2 -ftree-vectorize -march=native -fno-math-errno -std=c++14 -c -o core.o core.cpp
g++: error: unrecognized command line option '-std=c++14' (took 1 sec)
== Results of the build can be found in the log file(s) /tmp/eb-dbobppfh/easybuild-trouble-1.0-20200613.145414.aUEJA.log
ERROR: Build of /home/easybuild/subread.eb failed (err: ...)
```

Let's break this down a bit: during the `build` step of the installation
procedure EasyBuild was running `make` as a shell command, which
failed (exit code 2, so not zero).
The `make` command tripped over the compilation of `core.cpp` that failed because
`-std=c++14` is not a known option to the `g++` command.

OK fine, but now what? Can you spot something suspicious here?
Wait a minute... Why is `make` using `/usr/bin/g++` for the compilation?!
That's not where our toolchain compiler is installed,
that's somewhere under `/easybuild/software`.

Let's see what `/usr/bin/g++` is:

```shell
$ /usr/bin/g++ --version
g++ (GCC) 4.8.5 20150623 (Red Hat 4.8.5-39)
```

Oh my that's pretty ancient. That could definitely explain why it doesn't
know about the C++14 standard yet...

Your next step in this case should probably be figuring
out why `/usr/bin/g++` is being used rather than just `g++`, which would
result in using the right compiler version because EasyBuild sets up the build
environment carefully.

This is a fictitious example of course, but hopefully it gives you a feeling
of how errors that occur during the installation are handled.

## EasyBuild log files

Finding the cause of a problem that made the installation fail is, unfortunately, not always that straightforward...

EasyBuild includes the first 300 characters of the output produced by a failing
shell command in the error message, which is a sensible way to try include
actionable information in the error message while not flooding your terminal
with the full output of the command that failed.

In some cases there won't be any useful information in there however,
since the actual error message(s) could only appear way later, perhaps even after
the command was already running for several minutes.

In that case, you will have the dive into the log file that is created for
every installation, which is located in the unique temporary directory that
was created for the EasyBuild session.

See for example this output line from our earlier example error message:

```
== Results of the build can be found in the log file(s) /tmp/eb-dbobppfh/easybuild-trouble-1.0-20200613.145414.aUEJA.log
```

You can open this file with your favorite text editor or a tool like `less`
to take a look at the information collected in the log file, which includes
things like:

* informative messages produced by the EasyBuild framework and the easyblock
  describing how the installation is progressing;
* how the build environment was set up: which modules were loaded, which environment variables were set;
* the exact shell commands that were executed, and in which directory they were run;
* the full output produced by these commands, and their exit code;

Note that the installation log is also copied into each software installation
directory for successful installation, into the `easybuild` subdirectory.
For example:

```
/easybuild/software/HDF5/1.10.6-gompi-2020a/easybuild/easybuild-HDF5-1.10.6-20200609.131126.log
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
make[1]: Entering directory `/dev/shm/example/HDF5/1.10.6/gompi-2020a/hdf5-1.10.6/src'
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
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/trouble/1.0/GCC-9.3.0): ...
```

For software using a classic `configure` script, you may have to locate
and inspect the `config.log` file in the build directory to determine the underlying cause of an error. For software using CMake as a configuration tool you often have to check in
`CMakeOutput.log` or `CMakeError.log` for clues, which are sneakily hidden by CMake in a `CMakeFiles` subdirectory of the build directory.

As a side note here: as EasyBuild does not clean out old and failed builds you will need to eventually manually remove these build directories from the `buildpath` directory.

## Exercise

Let's work our way through a less smooth software installation,
using the easyconfig file that is provided in `/easybuild/tutorial/subread.eb`
in the tutorial container image.

For completeness sake, the contents are shown below.
Don't worry if most of this is still unclear to you, we'll get
to writing easyconfig files from scratch [later in this tutorial](../adding_support_software).

```python
easyblock = 'MakeCp'

name = 'Subread'
version = '2.0.1'

homepage = 'http://subread.sourceforge.net'
description = "High performance read alignment, quantification and mutation discovery"

toolchain = {'name': 'GCC', 'version': '8.4.0'}

# download from https://download.sourceforge.net/subread/subread-2.0.1-source.tar.gz
sources = ['subread-%(version)s-source.tar.gz']
checksums = ['d808eb5b1823c572cb45a97c95a3c5acb3d8e29aa47ec74e3ca1eb345787c17b']

start_dir = 'src'

buildopts = '-f Makefile.Linux CFLAGS="-fast"'

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

Start by copying the easyconfig file to your home directory, so you can make changes to it.

```shell
cd $HOME
cp /easybuild/tutorial/subread.eb .
```

Also make sure that the pre-installed software stack is available,
and that the EasyBuild module is loaded (unless you installed EasyBuild
yourself):

```
module use /easybuild/modules/all
module load EasyBuild
```

For this exercise, make sure EasyBuild is configured to
use `$HOME/easybuild` as `prefix`, and to use `/tmp/$USER` as `buildpath`:

```shell
export EASYBUILD_PREFIX=$HOME/easybuild
export EASYBUILD_BUILDPATH=/tmp/$USER
```

Check your configuration via `eb --show-config`.

Strictly speaking the configuration doesn't matter much for the sake of this
exercise, but it may help with the step-wise approach we'll take and
grasping the solutions.

Remember though: *no peeking* before you tried to solve each step yourself!

---

***Exercise 5.1**** - Sources*

Try to install the `subread.eb` easyconfig file, see what happens.

Can you fix the problem you run into, perhaps without even changing
the easyconfig file?

??? success "(click to show solution)"

    The installation fails because the source file `subread-2.0.1-source.tar.gz`
    is not found:
    ```
    $ eb subread.eb
    ...
    == FAILED: Installation ended unsuccessfully (build directory: /tmp/example/Subread/2.0.1/GCC-8.3.0): build failed (first 300 chars):
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
    mv subread-2.0.1-source.tar.gz $HOME/easybuild/sources/s/Subread/
    ```

    In case download is problematic, the source tarball is also available
    in `/easybuild/tutorial/`:

    ```shell
    cp /easybuild/tutorial/subread-2.0.1-source.tar.gz $HOME/easybuild/sources/s/Subread/
    ```

    Or, we can change the easyconfig file to specify the location where
    the easyconfig file can be downloaded from:
    ```python
    source_urls = ['https://download.sourceforge.net/subread/']
    sources = ['subread-%(version)s-source.tar.gz']
    ```
    Note that the `source_urls` value is a *list* of candidate URLs,
    *without* the filename of the source file.

    The source tarball is fairly large (23MB), so don't be alarmed if the download takes a little while.

    ```shell
    $ ls -lh $HOME/easybuild/sources/s/Subread
    total 23M
    -rw-rw-r-- 1 easybuild easybuild 23M Jun 13 17:42 subread-2.0.1-source.tar.gz
    ```

---

***Exercise 5.2**** - Toolchain*

After fixing the problem with missing source file, try the installation again.

What's wrong now? How can you fix it quickly?

Take into account that we just want to get this software package installed,
we don't care too much about details like the version of the dependencies or
the *toolchain* here...


??? success "(click to show solution)"

    The installation fails because the easyconfig specifies that GCC 8.4.0
    should be used as toolchain:
    ```
    $ eb subread.eb
    ...
    == FAILED: Installation ended unsuccessfully (build directory: /tmp/easybuild/Subread/2.0.1/GCC-8.3.0): build failed (first 300 chars):
    No module found for toolchain: GCC/8.4.0 (took 1 sec)
    ```

    We don't have this GCC version installed, but we do have GCC 9.3.0.
    So let's try using that instead.

    Edit the easyconfig file so it contains this:

    ```python
    toolchain = {'name': 'GCC', 'version': '9.3.0'}
    ```
    
    Or run the following `sed` command to change the toolchain version to `'9.3.0'`:

    ```shell
    sed -i 's/8.4.0/9.3.0/' subread.eb 
    ```
---

***Exercise 5.3**** - Build step*

With the first two problems fixed, now we can actually try to build the software.

Can you fix the next problem you run into?

??? success "(click to show solution)"

    The compilation fails, but the error message we see is incomplete due to 
    EasyBuild truncating the command output (only the 300 first characters of the output are shown):
    ```
    == FAILED: Installation ended unsuccessfully (build directory: /tmp/easybuild/Subread/2.0.1/GCC-9.3.0): build failed (first 300 chars):
    cmd " make -j 1 -f Makefile.Linux CFLAGS="-fast"" exited with exit code 2 and output:
    gcc  -mtune=core2  -O3 -DMAKE_FOR_EXON  -D MAKE_STANDALONE -D SUBREAD_VERSION=\""2.0.1"\"  -D_FILE_OFFSET_BITS=64    -fmessage-length=0  -ggdb  -fast   -c -o core.o core.c
    gcc: error: unrecognized command line opti (took 1 sec)
    ```

    If you open the log file and scroll to the end,
    the error is pretty obvious:
    ```
    gcc: error: unrecognized command line option -fast; did you mean -Ofast?
    make: *** [core.o] Error 1
    ```

    The easyconfig file hard specifies the `-fast` compiler flag via `CFLAGS=`
    to the build command:
    ```python
    buildopts = '-f Makefile.Linux CFLAGS="-fast"'
    ```

    EasyBuild sets up the build environment so there should be no need
    to hard specify compiler flags (certainly not incorrect ones), but
    it's good to keep an eye on it to make sure that the compiler flags
    specified by EasyBuild are actually being used.

    In this case we need to get rid of the '`CFLAGS="..."`' part in the `buildopts` value,
    but the "`-f Makefile.Linux`" part should stay.

    The problem can be fixed by changing the easyconfig file as follows:

    ```python
    buildopts = '-f Makefile.Linux'
    ```

    You can copy-paste and run this `sed` command to make the change without using an editor:

    ```shell
    sed -i "s/buildopts.*/buildopts = '-f Makefile.Linux'/" subread.eb
    ```

***Exercise 5.4**** - Sanity check*

After fixing the compilation issue, you're really close to getting the installation working, we promise!

Don't give up now, try one last time and fix the last problem that occurs...

??? success "(click to show solution)"
   
    Now the installation itself works but the sanity check fails,
    and hence the module file does not get generated:
    ```
    $ eb subread.eb
    ...
    == FAILED: Installation ended unsuccessfully (build directory: /tmp/easybuild/Subread/2.0.1/GCC-9.3.0): build failed (first 300 chars):
    Sanity check failed: sanity check command featureCounts --version exited with code 255
    (output: featureCounts: unrecognized option '--version'
    ...
    ```

    If you look at the full output in the log file you can see
    that the correct option to check the version of the `featureCounts` command
    is "`-v`" rather than "`--version`", so we need to fix this in the easyconfig file.

    Make the following change in the easyconfig file:
    ```python
    sanity_check_commands = ["featureCounts -v"]
    ```

    Or you can use this `sed` command to make that change:
    ```
    sed -i 's/featureCounts --version/featureCounts -v/' subread.eb
    ```

    After doing so, **you don't have to redo the installation
    from scratch**, you can use the `--module-only` option to only run the
    sanity check and generate the module file again:
    ```
    eb subread.eb --module-only
    ```

---

In the end, you should be able to install Subread 2.0.1 with the GCC 9.3.0 toolchain by fixing the problems with the `subread.eb` easyconfig file.

Check your work by manually loading the module and checking the version
via the `featureCounts` command, which should look like this:

```shell
$ featureCounts -v
featureCounts v2.0.1
```
