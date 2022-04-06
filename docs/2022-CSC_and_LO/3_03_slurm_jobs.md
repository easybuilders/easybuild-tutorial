# Submitting installations as Slurm jobs

*[[back: Using hooks to customise EasyBuild]](3_02_hooks.md)*

---

EasyBuild can submit jobs to different backends including Slurm to install software,
to *distribute* the often time-consuming installation of a set of software applications and
the dependencies they require to a cluster. Each individual package is installed in a separate
job and job dependencies are used to manage the dependencies between package so that no build
is started before the dependencies are in place.

This is done via the ``--job`` command line option.

It is important to be aware of some details before you start using this, which we'll cover here.

!!! Warning "This section is not supported on LUMI, use at your own risk"

    EasyBuild on LUMI is currently not fully configured to support job submission via Slurm. Several
    changes would be needed to the configuration of EasyBuild, including the location of the
    temporary files and build directory. Those have to be made by hand. 

    Due to the setup of the central software stack, this feature is currently useless to install
    the central stack. For user installations, there are also limitations as the enviornment
    on the compute nodes is different from the login nodes so, e.g., different locations for
    temporary files are being used. These would only be refreshed if the EasyBuild configuration
    modules are reloaded on the compute nodes which cannot be done currently in the way Slurm
    job submission is set up in EasyBuild.

    Use material in this section with care; it has not been completely tested.
    

## Configuration

The EasyBuild configuration that is active at the time that ``eb --job`` is used
will be *passed down* into the submitted job automatically, via command line options to the ``eb``
command that is run in the job script.

This includes not only command line options used next to ``--job``, but also configuration settings
that are specified via an [EasyBuild configuration file](configuration.md#configuration-files) or through
[``$EASYBUILD_*`` environment variables](configuration.md#easybuild_-environment-variables).

This implies that any EasyBuild configuration files or ``$EASYBUILD_*`` environment variables
that are in place in the job environment are most likely *irrelevant*, since configuration settings
they specify they will most likely be overruled by the corresponding command line options.
It does also imply however that the EasyBuild configuration that is in place when ``eb --job`` is used
does also work on the compute nodes to which the job is submitted.


## Using ``eb --job``

### Job backend

The default job backend in EasyBuild v4.x is [``GC3Pie``](https://gc3pie.readthedocs.io).
To let EasyBuild submit jobs to Slurm instead, you should set the ``job-backend`` configuration setting
to ``Slurm``, for example by setting the corresponding environment variable:

```shell
export EASYBUILD_JOB_BACKEND='Slurm'
```

On LUMI this is taken care of in the EasyBuild configuration modules such as ``EasyBuild-user``.


### Job resources

To submit an installation as a job, simply use ``eb --job``:

```shell
eb example.eb --job
```

By default, EasyBuild will submit single-core jobs requesting for 24 hours of walltime.
You can tweak the requested resources via the ``job-cores`` and ``job-max-walltime`` configuration options.
For example:

```shell
# submit job to install example, using 5 cores and 2 hours of max. walltime
eb example.eb --job --job-cores 5 --job-max-walltime 2
```

Note that not all ``job-*`` configuration settings apply to all job backends,
see the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Submitting_jobs.html) for more details.

### Controlling Slurm submission options

When using Slurm as a job backend, EasyBuild will automatically generate job scripts which
use the ``eb`` command to perform a single installation. These scripts will be submitted
using the ``sbatch`` command.

EasyBuild currently doesn't provide away to customize the Slurm submission options,
for example to submit to a particular partition, or to use a particular account,
build you can set the corresponding ``$SBATCH_*`` environment variables prior to running ``eb --job``.

For example, to specify a particular account that should be used for the jobs submitted by EasyBuild
(equivalent with using the ``-A`` or ``--account`` command line option for ``sbatch``):

```shell
export SBATCH_ACCOUNT='project_XXXXXXXXX'
```

Or to submit to a particular Slurm partition (equivalent with the ``-p`` or ``--partition`` option for ``sbatch``):

```shell
export SBATCH_PARTITION='small'
```

For more information about supported ``$SBATCH_*`` environment variables,
see the [Slurm documentation](https://slurm.schedmd.com/sbatch.html#lbAJ).

## Combining ``--job`` and ``--robot``

If one or more dependencies are still missing for the software you want to install,
you can combine ``--job`` and ``--robot`` to get EasyBuild to submit a *separate* job
for each of the installations. These jobs will *not* ``--robot``, they will each only
perform a single installation.

Dependencies between jobs will be "registered" at submission time, so Slurm will put jobs
on hold until the jobs that install the required (build) dependencies have completed successfully,
and cancel jobs if the job to install a dependency failed for some reason.

## Attention points

There are a couple of important things to keep an eye on when submitting installations as jobs...

### Differences on cluster workernodes

Sometimes the resources available on the login nodes and cluster workernodes are slightly different,
and you may need to take this into account in your EasyBuild configuration.

For example, plenty of disk space may be available in the `/tmp` temporary filesystem on a login node,
while the workernodes require you to use a different location for temporary files and directories.
As a result, you may need to slightly change your EasyBuild configuration when submitting installations
as jobs, to avoid that they fail almost instantly due to a lack of disk space.

Keep in mind that the active EasyBuild configuration is passed down into the submitted jobs,
so any configuration that is present on the workernodes may not have any effect.

For example, on LUMI it is possible to use ``$XDG_RUNTIME_DIR`` on the login nodes which has
the advantage that any leftovers of failed builds will be cleaned up when the user ends their last
login session on that node, but it is not possible to do so on the compute nodes.

```shell
# EasByuild is configured to use /tmp/$USER on the login node
uan01 $ eb --show-config | grep buildpath
buildpath      (E) = /run/user/XXXXXXXX/easybuild/build

# use /dev/shm/$USER for build directories when submitting installations as jobs
login01 $ eb --job --buildpath /dev/shm/$USER/easybuild example.eb --robot
```


### Temporary log files and build directories

The problems for the temporary log files are twofold. First, they may end up in a place
that is not available on the compute nodes. E.g., for the same reasons as for the build
path, the LUMI EasyBuild configuration will place the temporary files in a subdirectory of
``$XDG_RUNTIME_DIR`` on the loginnodes but a subdirectory of ``/dev/shm/$USER`` on the
compute nodes. The second problem however is that if an installation fails, those log files are
not even accessible anymore which may leave you wondering about the actual cause of the failing 
installation...

To remedy this, there are a couple of EasyBuild configuration options you can use:

* You can use ``--tmp-logdir`` to specify a different location where EasyBuild should store temporary log files,
  for example:
  ```shell
  $ eb --job example.eb --tmp-logdir $HOME/eb_tmplogs
  ```
  This will move at least the log file to a suitable place.

* If you prefer having the entire log file stored in the Slurm job output files,
  you can use ``--logtostdout`` when submitting the jobs. This will result in extensive logging
  to your terminal window when submitting the jobs, but it will also make EasyBuild
  log to ``stdout`` when the installation is running in the job, and hence the log messages will be
  captured in the job output files.

The build directory of course also suffers from the problem of being no longer accessible if the
installation fails, but there it is not so easy to find a solution. Building on a shared file system
is not only much slower, but in particular on parallel file systems like GPFS/SpectrumScale, Lustre
or BeeGFS buiding sometimes fails in strange ways. One thing you can consider if you cannot do the
build on a login node (e.g., because the code is not suitable for cross-compiling or the configure
system does tests that would fail on the login node), is to rety the installation in an
interactive job,  so you can inspect the build directory after the installation fails.

### Lock files

EasyBuild creates [locks](https://docs.easybuild.io/en/latest/Locks.html)
to prevent that the same installation is started multiple times on
different system to the same installation directory.

If an installation fails or gets interrupted, EasyBuild cleans up those locks automatically.

However, if a Slurm job that is using EasyBuild to install software gets cancelled (because it
ran out of walltime, tried to consume too much memory, through an ``scancel`` command, etc.),
EasyBuild will not get the chance to clean up the lock file.

If this occurs you will need to either clean up the lock file (which is located in the `software/.locks`
subdirectory of ``installpath``) manually, or re-submit the job with ``eb --job --ignore-locks``.

## Example

As an example, we will let EasyBuild submit jobs to install ``AUGUSTUS`` with the ``foss/2020b`` toolchain.

!!! Warning "This example does not work on LUMI"

    Note that this is an example using the FOSS common toolchain. For this reason it does not work on
    LUMI.

### Configuration

Before using ``--job``, let's make sure that EasyBuild is properly configured:

```shell
# Load the EasyBuild-user module (central installations will not work at all
# using job submission)
module load LUMI/21.12
module load partition/C
module load EasyBuild-user

# use ramdisk for build directories
export EASYBUILD_BUILDPATH=/dev/shm/$USER/build
export EASYBUILD_TMPDIR=/dev/shm/$USER/tmp

# use Slurm as job backend
export EASYBUILD_JOB_BACKEND=Slurm
```


We will also need to inform Slurm that jobs should be submitted into a particular account, and
in a particular partition:

```shell
export SBATCH_ACCOUNT=project_XXXXXXXXX
export SBATCH_PARTITION='small'
```

This will be picked up by the ``sbatch`` commands that EasyBuild will run to submit the software installation jobs.


### Submitting jobs to install AUGUSTUS

Now we can let EasyBuild submit jobs for AUGUSTUS.

Let's first check what is still missing:

```shell
$ eb AUGUSTUS-3.4.0-foss-2020b.eb --missing
...
11 out of 61 required modules missing:

* HTSlib/1.11-GCC-10.2.0 (HTSlib-1.11-GCC-10.2.0.eb)
* lpsolve/5.5.2.11-GCC-10.2.0 (lpsolve-5.5.2.11-GCC-10.2.0.eb)
* Boost/1.74.0-GCC-10.2.0 (Boost-1.74.0-GCC-10.2.0.eb)
* GSL/2.6-GCC-10.2.0 (GSL-2.6-GCC-10.2.0.eb)
* SAMtools/1.11-GCC-10.2.0 (SAMtools-1.11-GCC-10.2.0.eb)
* BCFtools/1.11-GCC-10.2.0 (BCFtools-1.11-GCC-10.2.0.eb)
* METIS/5.1.0-GCCcore-10.2.0 (METIS-5.1.0-GCCcore-10.2.0.eb)
* BamTools/2.5.1-GCC-10.2.0 (BamTools-2.5.1-GCC-10.2.0.eb)
* MPFR/4.1.0-GCCcore-10.2.0 (MPFR-4.1.0-GCCcore-10.2.0.eb)
* SuiteSparse/5.8.1-foss-2020b-METIS-5.1.0 (SuiteSparse-5.8.1-foss-2020b-METIS-5.1.0.eb)
* AUGUSTUS/3.4.0-foss-2020b (AUGUSTUS-3.4.0-foss-2020b.eb)
```

Several dependencies are not installed yet, so we will need to use ``--robot`` to ensure that
EasyBuild also submits jobs to install these first.

To speed up the installations a bit, we will request 8 cores for each submitted job (via ``--job-cores``).
That should be sufficient to let each installation finish in (well) under 1 hour,
so we only request 1 hour of walltime per job (via ``--job-max-walltime``).

In order to have some meaningful job output files, we also enable trace mode (via ``--trace``).

```
$ eb AUGUSTUS-3.4.0-foss-2020b.eb --job --job-cores 8 --job-max-walltime 1 --robot --trace
...
== resolving dependencies ...
...
== List of submitted jobs (11): Boost-1.74.0-GCC-10.2.0 (Boost/1.74.0-GCC-10.2.0): 1000011; GSL-2.6-GCC-10.2.0 (GSL/2.6-GCC-10.2.0): 1000004; SAMtools-1.11-GCC-10.2.0 (SAMtools/1.11-GCC-10.2.0): 1000005; HTSlib-1.11-GCC-10.2.0 (HTSlib/1.11-GCC-10.2.0): 1000006; BCFtools-1.11-GCC-10.2.0 (BCFtools/1.11-GCC-10.2.0): 1000001; lpsolve-5.5.2.11-GCC-10.2.0 (lpsolve/5.5.2.11-GCC-10.2.0): 1000007; BamTools-2.5.1-GCC-10.2.0 (BamTools/2.5.1-GCC-10.2.0): 1000008; METIS-5.1.0-GCCcore-10.2.0 (METIS/5.1.0-GCCcore-10.2.0): 1000009; MPFR-4.1.0-GCCcore-10.2.0 (MPFR/4.1.0-GCCcore-10.2.0): 1000010; SuiteSparse-5.8.1-foss-2020b-METIS-5.1.0 (SuiteSparse/5.8.1-foss-2020b-METIS-5.1.0): 1000002; AUGUSTUS-3.4.0-foss-2020b (AUGUSTUS/3.4.0-foss-2020b): 1000003
== Submitted parallel build jobs, exiting now
```

### Inspecting the submitted jobs

Once EasyBuild has submitted the jobs, we can inspect them via Slurm's ``squeue`` command:

```
$ squeue -u $USER -la
  JOBID PARTITION     NAME     USER    STATE   TIME TIME_LIMI  NODES NODELIST(REASON)
1000001     small BCFtools  user123  PENDING   0:00   2:00:00      1 (Dependency)
1000002     small SuiteSpa  user123  PENDING   0:00   2:00:00      1 (Dependency)
1000003     small AUGUSTUS  user123  PENDING   0:00   2:00:00      1 (Dependency)
1000004     small GSL-2.6-  user123  RUNNING   0:21   2:00:00      1 node003
1000005     small SAMtools  user123  RUNNING   0:21   2:00:00      1 node007
1000006     small HTSlib-1  user123  RUNNING   0:21   2:00:00      1 node007
1000007     small lpsolve-  user123  RUNNING   0:21   2:00:00      1 node011
1000008     small BamTools  user123  RUNNING   0:21   2:00:00      1 node011
1000009     small METIS-5.  user123  RUNNING   0:21   2:00:00      1 node013
1000010     small MPFR-4.1  user123  RUNNING   0:21   2:00:00      1 node029
1000011     small Boost-1.  user123  RUNNING   0:24   2:00:00      1 node029
```

Note that 3 jobs can not be started yet, because those installations require on one or more
missing dependencies. As soon as the jobs for those dependencies (successfully) complete,
these jobs will be able to start.

### Final result

After about 20 minutes, AUGUSTUS and all missing dependencies should be installed:

```
$ ls -lrt $HOME/EasyBuild/modules/.../*.lua | tail -11
-rw-rw----. 1 example  example  1634 Mar 29 10:13 /users/example/easybuild/modules/all/HTSlib/1.11-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1792 Mar 29 10:13 /users/example/easybuild/modules/all/SAMtools/1.11-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1147 Mar 29 10:13 /users/example/easybuild/modules/all/BamTools/2.5.1-GCC-10.2.0.lua
-rw-rw----. 1 example  example   957 Mar 29 10:13 /users/example/easybuild/modules/all/lpsolve/5.5.2.11-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1549 Mar 29 10:13 /users/example/easybuild/modules/all/METIS/5.1.0-GCCcore-10.2.0.lua
-rw-rw----. 1 example  example  1525 Mar 29 10:14 /users/example/easybuild/modules/all/GSL/2.6-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1221 Mar 29 10:15 /users/example/easybuild/modules/all/MPFR/4.1.0-GCCcore-10.2.0.lua
-rw-rw----. 1 example  example  1678 Mar 29 10:15 /users/example/easybuild/modules/all/BCFtools/1.11-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1292 Mar 29 10:21 /users/example/easybuild/modules/all/Boost/1.74.0-GCC-10.2.0.lua
-rw-rw----. 1 example  example  1365 Mar 29 10:28 /users/example/easybuild/modules/all/SuiteSparse/5.8.1-foss-2020b-METIS-5.1.0.lua
-rw-rw----. 1 example  example  2233 Mar 29 10:30 /users/example/easybuild/modules/all/AUGUSTUS/3.4.0-foss-2020b.lua

$ module avail AUGUSTUS

-- EasyBuild managed user software for software stack ... --
   AUGUSTUS/3.4.0-foss-2020b
```

---

*[[next: Module naming schemes]](3_04_module_naming_scheme.md)*
