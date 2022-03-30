# Submitting installations as Slurm jobs

*[[back: Using hooks to customise EasyBuild]](3_02_hooks.md)*

---

EasyBuild can submit jobs to different backends including Slurm to install software,
to *distribute* the often time-consuming installation of a set of software applications and
the dependencies they require to a cluster.

This is done via the ``--job`` command line option.

It is important to be aware of some details before you start using this, which we'll cover here.

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


## Using ``eb --job``

### Job backend

The default job backend in EasyBuild v4.x is [``GC3Pie``](https://gc3pie.readthedocs.io).
To let EasyBuild submit jobs to Slurm instead, you should set the ``job-backend`` configuration setting
to ``Slurm``, for example by setting the corresponding environment variable:

```shell
export EASYBUILD_JOB_BACKEND='Slurm'
```

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
export SBATCH_ACCOUNT='example_project'
```

Or to submit to a particular Slurm partition (equivalent with the ``-p`` or ``--partition`` option for ``sbatch``):

```shell
export SBATCH_PARTITION='example_partition'
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

For example, if you commonly use `/tmp/$USER` for build directories on a login node,
you may need to tweak that when submitting jobs to use a different location:

```shell
# EasByuild is configured to use /tmp/$USER on the login node
login01 $ eb --show-config | grep buildpath
buildpath      (E) = /tmp/example

# use /localdisk/$USER for build directories when submitting installations as jobs
login01 $ eb --job --buildpath /localdisk/$USER example.eb --robot
```

### Temporary log files and build directories

The temporary log file that EasyBuild creates is most likely going to end up on the local disk
of the workernode on which the job was started (by default in `$TMPDIR` or `/tmp`).
If an installation fails, the job will finish and temporary files will likely be cleaned up instantly,
which may leave you wondering about the actual cause of the failing installation...

To remedy this, there are a couple of EasyBuild configuration options you can use:

* You can use ``--tmp-logdir`` to specify a different location where EasyBuild should store temporary log files,
  for example:
  ```shell
  $ eb --job example.eb --tmp-logdir $HOME/eb_tmplogs
  ```

* If you prefer having the entire log file stored in the Slurm job output files,
  you can use ``--logtostdout`` when submitting the jobs. This will result in extensive logging
  to your terminal window when submitting the jobs, but it will also make EasyBuild
  log to ``stdout`` when the installation is running in the job, and hence the log messages will be
  captured in the job output files.

The same remark applies to build directories: they should be on a local filesystem (to avoid problems
that often occur when building software on a parallel filesystem like GPFS or Lustre),
which will probably be cleaned up automatically when a job fails. Here it is less easy to provide
general advice on how to deal with this, but one thing you can consider is retrying the installation
in an interactive job, so you can inspect the build directory after the installation fails.

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

### Configuration

Before using ``--job``, let's make sure that EasyBuild is properly configured:

```shell
# use $HOME/easybuild for software, modules, sources, etc.
export EASYBUILD_PREFIX=$HOME/easybuild

# use ramdisk for build directories
export EASYBUILD_BUILDPATH=/dev/shm/$USER

# use Slurm as job backend
export EASYBUILD_JOB_BACKEND=Slurm
```

In addition, add the path to the centrally installed software to ``$MODULEPATH`` via ``module use``:

```shell
module use /easybuild/modules/all
```

Load the EasyBuild module:

```shell
module load EasyBuild
```

Let's assume that we also need to inform Slurm that jobs should be submitted into a particular account:

```shell
export SBATCH_ACCOUNT=example_project
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

To speed up the installations a bit, we will request 10 cores for each submitted job (via ``--job-cores``).
That should be sufficient to let each installation finish in (well) under 1 hour,
so we only request 1 hour of walltime per job (via ``--job-max-walltime``).

In order to have some meaningful job output files, we also enable trace mode (via ``--trace``).

```
$ eb AUGUSTUS-3.4.0-foss-2020b.eb --job --job-cores 10 --job-max-walltime 1 --robot --trace
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
$ ls -lrt $HOME/easybuild/modules/all/*/*.lua | tail -11
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

$ module use $HOME/easybuild/modules/all

$ module avail AUGUSTUS

-------- /users/hkenneth/easybuild/modules/all --------
   AUGUSTUS/3.4.0-foss-2020b
```

---

*[[next: Module naming schemes]](3_04_module_naming_scheme.md)*
