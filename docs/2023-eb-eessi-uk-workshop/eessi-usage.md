# Using EESSI

If the EESSI pilot repository is available, all you need to do is set up your shell environment,
and you can start using the software installations that EESSI provides.

## Setting up your environment

To set up the EESSI environment, simply run the command:

``` { .bash .copy }
source /cvmfs/pilot.eessi-hpc.org/latest/init/bash
```

!!! warning
    The EESSI pilot software stack is **NOT READY FOR PRODUCTION!**

    Do not use it for production work, and be careful when testing it on production systems!

This may take a while as data is downloaded from a Stratum 1 server which is
part of the CernVM-FS infrastructure to distribute files. You should see the
following output:

``` { .yaml .no-copy }
Found EESSI pilot repo @ /cvmfs/pilot.eessi-hpc.org/versions/2021.12!
archspec says x86_64/intel/skylake_avx512 # (1)!
Using x86_64/intel/skylake_avx512 as software subdirectory.
Using /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/skylake_avx512/modules/all as the directory to be added to MODULEPATH.
Found Lmod configuration file at /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/skylake_avx512/.lmod/lmodrc.lua
Initializing Lmod...
Prepending /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/skylake_avx512/modules/all to $MODULEPATH...
Environment set up to use EESSI pilot software stack, have fun!
[EESSI pilot 2021.12] $ # (2)!
```

1.  What is reported here depends on the CPU architecture of the machine you are
    running the `source` command.
2.  This is the prompt indicating that you have access to the EESSI software
    stack.

The last line is the shell prompt.

:clap: Your environment is now set up, you are ready to start running software provided by EESSI!

## Basic commands to access software provided via EESSI

EESSI provides software through environment module files and [Lmod](https://lmod.readthedocs.io).

To see which modules (and extensions) are available, run:

``` { .bash .copy }
module avail
```

Below is a short excerpt of the output produced by `module avail`, showing 10 modules only.
```
   PyYAML/5.3-GCCcore-9.3.0
   Qt5/5.14.1-GCCcore-9.3.0
   Qt5/5.15.2-GCCcore-10.3.0                               (D)
   QuantumESPRESSO/6.6-foss-2020a
   R-bundle-Bioconductor/3.11-foss-2020a-R-4.0.0
   R/4.0.0-foss-2020a
   R/4.1.0-foss-2021a                                      (D)
   re2c/1.3-GCCcore-9.3.0
   re2c/2.1.1-GCCcore-10.3.0                               (D)
   RStudio-Server/1.3.1093-foss-2020a-Java-11-R-4.0.0
```

Load modules with `module load package/version`, e.g.,
`module load R/4.1.0-foss-2021a`, and try out the software. See below for a short
session

```
[EESSI pilot 2021.12] $ module load R/4.1.0-foss-2021a
[EESSI pilot 2021.12] $ which R
/cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/skylake_avx512/software/R/4.1.0-foss-2021a/bin/R
[EESSI pilot 2021.12] $ R --version
R version 4.1.0 (2021-05-18) -- "Camp Pontanezen"
Copyright (C) 2021 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under the terms of the
GNU General Public License versions 2 or 3.
For more information about these matters see
https://www.gnu.org/licenses/.
```

## Running EESSI demos

To really experience how using EESSI can significantly facilitate the work of researchers,
we recommend running one or more of the EESSI demos.

First, clone the ``eessi-demo`` Git repository, and move into the resulting directory:

``` { .bash .copy }
git clone https://github.com/EESSI/eessi-demo.git
cd eessi-demo
```

The contents of the directory should be something like this:

```
$ ls -l
drwxr-xr-x  5 example  users    160 Nov 23  2020 Bioconductor
drwxr-xr-x  3 example  users     96 Jan 26 20:17 CitC
drwxr-xr-x  5 example  users    160 Jan 26 20:17 GROMACS
-rw-r--r--  1 example  users  18092 Jan 26 20:17 LICENSE
drwxr-xr-x  3 example  users     96 Jan 26 20:17 Magic_Castle
drwxr-xr-x  4 example  users    128 Nov 24  2020 OpenFOAM
-rw-r--r--  1 example  users    546 Jan 26 20:17 README.md
drwxr-xr-x  5 example  users    160 Nov 23  2020 TensorFlow
drwxr-xr-x  6 example  users    192 Jan 26 20:17 scripts
```

The directories we care about are those that correspond to particular scientific software,
like ``Bioconductor``, ``GROMACS``, ``OpenFOAM``, ``TensorFlow``, ...

Each of these contains a ``run.sh`` script that can be used to start a small
example run with that software. Every example takes a couple of minutes to run,
even with limited resources only.

## Example: running GROMACS

Let's try running the GROMACS example.

First, we need to make sure that [our environment is set up to use EESSI](../setting_up_environment):

``` { .bash .copy }
source /cvmfs/pilot.eessi-hpc.org/latest/init/bash
```

Change to the ``GROMACS`` subdirectory of the ``eessi-demo`` Git repository, and execute the ``run.sh`` script:

``` { .no-copy }
[EESSI pilot 2021.12] $ cd GROMACS
[EESSI pilot 2021.12] $ ./run.sh
```

Shortly after starting the script you should see output as shown below, which indicates that GROMACS has started
running:

``` { .no-copy }
GROMACS:      gmx mdrun, version 2020.1-EasyBuild-4.5.0
Executable:   /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/haswell/software/GROMACS/2020.1-foss-2020a-Python-3.8.2/bin/gmx
...
starting mdrun 'Protein'
1000 steps,      2.5 ps.
```

[*next: Use Cases for EESSI*](eessi-use-cases.md) - [*(back to overview page)*](index.md)
