# Installing software with EasyBuild

You should now be able to make an informed decision on which easyconfig file you should use to
make EasyBuild install the software you require.

As mentioned before, installing an easyconfig is as simple as passing it to the `eb` command.

So, let's try to install SAMtools version 1.14:

```shell
$ eb SAMtools-1.14-GCC-11.2.0.eb
== Temporary log file in case of crash /tmp/eb-os2fd8gv/easybuild-yda39z4b.log
== processing EasyBuild easyconfig /home/achilles/easybuild/easybuild-easyconfigs/easybuild/easyconfigs/s/SAMtools/SAMtools-1.14-GCC-11.2.0.eb
== building and installing SAMtools/1.14-GCC-11.2.0...
== fetching files...
== creating build dir, resetting environment...
== unpacking...
== ... (took 1 secs)
== patching...
== preparing...
== ... (took 3 secs)
== configuring...
== ... (took 6 secs)
== building...
== ... (took 46 secs)
== testing...
== installing...
== taking care of extensions...
== restore after iterating...
== postprocessing...
== sanity checking...
== ... (took 1 secs)
== cleaning up...
== creating module...
== ... (took 1 secs)
== permissions...
== packaging...
== COMPLETED: Installation ended successfully (took 1 min 0 secs)
== Results of the build can be found in the log file(s) /project/def-maintainers/achilles/Rocky8/zen2/software/SAMtools/1.14-GCC-11.2.0/easybuild/easybuild-SAMtools-1.14-20220502.121241.log
== Build succeeded for 1 out of 1
== Temporary log file(s) /tmp/eb-os2fd8gv/easybuild-yda39z4b.log* have been removed.
== Temporary directory /tmp/eb-os2fd8gv has been removed.
```

That was... easy. Is that really all there is to it? Well, almost...

### Enabling dependency resolution

The SAMtools installation worked like a charm, but remember that all required dependencies were already
available ([see the section on checking dependencies](../basic_usage/#dry-run)).

If we try this with the `BCFtools-1.14-GCC-11.2.0.eb`, for which the required `GSL` and `HTSlib` dependencies are not available yet, it's less successful:

```shell
$ eb BCFtools-1.14-GCC-11.2.0.eb -M

3 out of 23 required modules missing:

* GSL/2.7-GCC-11.2.0 (GSL-2.7-GCC-11.2.0.eb)
* HTSlib/1.14-GCC-11.2.0 (HTSlib-1.14-GCC-11.2.0.eb)
* BCFtools/1.14-GCC-11.4.0 (BCFtools-1.14-GCC-11.2.0.eb)
```

```shell
$ eb BCFtools-1.14-GCC-11.2.0.eb
...
== preparing...
== FAILED: Installation ended unsuccessfully (build directory: /tmp/example/build/BCFtools/1.14/GCC-11.2.0): build failed (first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.14-GCC-11.2.0, GSL/2.7-GCC-11.2.0 (took 1 secs)
== Results of the build can be found in the log file(s) /tmp/eb-66a5glv6/easybuild-BCFtools-1.14-20220502.145732.ElHDN.log
ERROR: Build of /easybuild/software/EasyBuild/20220501-dev/easybuild/easyconfigs/b/BCFtools/BCFtools-1.14-GCC-11.2.0.eb failed (err: 'build failed (first 300 chars): Missing modules for dependencies (use --robot?): HTSlib/1.14-GCC-11.2.0, GSL/2.7-GCC-11.2.0')
```

Oh my, what's this all about?

If we filter the output a bit and focus on the actual error, the problem is clear:

```
Missing modules for dependencies (use --robot?): HTSlib/1.14-GCC-11.2.0, GSL/2.7-GCC-11.2.0
```

The required dependencies `HTSlib/1.14-GCC-11.2.0` and `GSL/2.7-GCC-11.2.0` are not installed yet,
and EasyBuild does not automatically install missing dependencies unless it is told to do so.

It helpfully suggests to use the `--robot` command line option, so let's try that:

```shell
$ eb BCFtools-1.14-GCC-11.2.0.eb --robot
...
== resolving dependencies ...
...
== building and installing HTSlib/1.14-GCC-11.2.0...
...
== COMPLETED: Installation ended successfully (took 14 sec)
...
== building and installing GSL/2.7-GCC-11.2.0...
...
== COMPLETED: Installation ended successfully (took 1 min 10 sec)
...
== building and installing BCFtools/1.14-GCC-11.2.0...
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

We will redo the installation of `BCFtools-1.14-GCC-11.2.0.eb` by passing the `--rebuild`
option to the `eb` command (try yourself what happens if you don't use the `--rebuild` option!):

```shell
$ export EASYBUILD_TRACE=1
$ eb BCFtools-1.14-GCC-11.2.0.eb --rebuild
...
== configuring...                                                                                                                    
  >> running command:                                                                                                                
        [started at: 2022-05-02 15:05:42]                                                                                            
        [working dir: /tmp/example/build/BCFtools/1.14/GCC-11.2.0/bcftools-1.14]                                                     
        [output logged in /tmp/eb-tus8o1g4/easybuild-run_cmd-mjc8gj6x.log]                                                           
        /home/easybuild/.local/easybuild/sources/generic/eb_v4.5.5.dev0/ConfigureMake/config.guess                                   
  >> command completed: exit 0, ran in < 1s                                                                                          
  >> running command:                                                                                                                
        [started at: 2022-05-02 15:05:42]                                                                                            
        [working dir: /tmp/example/build/BCFtools/1.14/GCC-11.2.0/bcftools-1.14]                                                     
        [output logged in /tmp/eb-tus8o1g4/easybuild-run_cmd-cv6vncds.log]                                                           
        ./configure --prefix=/home/example/easybuild/software/BCFtools/1.14-GCC-11.2.0  --build=x86_64-pc-linux-gnu  --host=x86_64-pc-linux-gnu --with-htslib=$EBROOTHTSLIB --enable-libgsl                                                                      
  >> command completed: exit 0, ran in 00h00m01s                                                                         
== ... (took 1 secs)                                                                                                                 
== building...                                                                                                                       
  >> running command:                                                                                                                
        [started at: 2022-05-02 15:05:43]                                                                                            
        [working dir: /tmp/example/build/BCFtools/1.14/GCC-11.2.0/bcftools-1.14]                                                     
        [output logged in /tmp/eb-tus8o1g4/easybuild-run_cmd-wtsxpxf2.log]                                                           
        make  -j 8                                                                                                                   
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
   BCFtools/1.14-GCC-11.2.0    GSL/2.7-GCC-11.2.0       SAMtools/1.14-GCC-11.2.0
   EasyBuild/4.4.5             HTSlib/1.14-GCC-11.2.0   bzip2/1.0.8

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
$ module load BCFtools/1.14-GCC-11.2.0

$ module list
Currently Loaded Modules:
  1) EasyBuild/4.4.5                7) XZ/5.2.5-GCCcore-11.2.0
  2) GCCcore/11.2.0                 8) OpenSSL/1.1
  3) zlib/1.2.11-GCCcore-11.2.0     9) cURL/7.78.0-GCCcore-11.2.0
  4) binutils/2.37-GCCcore-11.2.0  10) HTSlib/1.14-GCC-11.2.0
  5) GCC/11.2.0                    11) GSL/2.7-GCC-11.2.0
  6) bzip2/1.0.8-GCCcore-11.2.0    12) BCFtools/1.14-GCC-11.2.0

$ bcftools --version
bcftools 1.14
Using htslib 1.14
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

Please do not spoil solutions for others before they have been discussed by the tutorial organisers.

The exercises are based on the easyconfig files included with EasyBuild 4.4.5.

---

***Exercise S.1**** - Installing software*

Install version 3.6.0 of the `h5py` Python package and all missing dependencies,
using the `foss/2021b` toolchain, into `/tmp/$USER/easybuild`,
while leveraging the already installed software available from `/easybuild`.

Enable trace output so you can see which parts of the installation take a while.

??? success "(click to show solution)"
    First, determine the easyconfig file we can use for this:
    ```shell
    $ eb -S 'h5py-3.6.0.*foss-2021b'
    CFGS1=/home/easybuilder/easybuild/software/EasyBuild/4.4.5/easybuild/easyconfigs/h/h5py
    * $CFGS1/h5py-3.6.0-foss-2021b.eb
    ```

    Make sure the pre-installed software in `/easybuild/` is available:
    ```shell
    module use /easybuild/modules/all
    ```

    Check which dependencies are missing to install this `h5py` easyconfig:
    ```shell
    $ eb h5py-3.6.0-foss-2021b.eb --missing

    2 out of 63 required modules missing:

    * pkgconfig/1.5.5-GCCcore-11.2.0-python (pkgconfig-1.5.5-GCCcore-11.2.0-python.eb)
    * h5py/3.6.0-foss-2021b (h5py-3.6.0-foss-2021b.eb)
    ```

    Install `h5py` by specifying the easyconfig file and enabling dependency resolution via `--robot`,
    while indicating that we want to install the software into `/tmp/$USER/easybuild` using the `--installpath`
    option. Also make sure that trace mode is enabled by defining the `$EASYBUILD_TRACE` environment variable.
    ```shell
    $ export EASYBUILD_TRACE=1
    $ eb h5py-3.6.0-foss-2021b.eb --robot --installpath /tmp/$USER/easybuild
    ...
    == building and installing pkgconfig/1.5.5-GCCcore-11.2.0-python...
    ...
    == building and installing h5py/3.6.0-foss-2021b...
    ...
    == installing...
      >> running command:
            [started at: 2022-05-02 13:38:37]
            [working dir: /tmp/example/h5py/3.6.0/foss-2021b/h5py-3.6.0]
            [output logged in /tmp/eb-rjjkbqe1/easybuild-run_cmd-d_dkc4iz.log]  
            HDF5_MPI=ON HDF5_DIR="$EBROOTHDF5" H5PY_SETUP_REQUIRES=0  pip install --prefix=/tmp/achilles/easybuild/software/h5py/3.6.0-foss-2021b  --no-deps --ignore-installed  --no-index  --no-build-isolation  .
      >> command completed: exit 0, ran in 00h01m43s
    ...
    == COMPLETED: Installation ended successfully (took 2 min 0 sec)
    ...
    == Build succeeded for 2 out of 2
    ```

    The trace output shows that most time is spent in the installing command,
    which runs `pip install`.

---

***Exercise S.2**** - Using installed software*

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
    h5py/3.6.0-foss-2021b
    ```

    ```shell
    module load h5py/3.6.0-foss-2021b
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
    -rw-rw-r-- 1 example example 800 Mai 2 15:48 empty.hdf5

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

Feel free to ask questions in the `#tutorial-isc22` channel in the [EasyBuild
Slack](https://docs.easybuild.io/en/latest/#getting-help),
we're happy to help!

---

[*next: Troubleshooting*](troubleshooting.md) - [*(back to overview page)*](index.md)
