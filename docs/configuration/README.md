# Configuration

After installing EasyBuild, you should **configure** it.
EasyBuild should work fine out-of-the-box if you use Lmod
as your modules tool; if you are not using Lmod, please see <a href="#modules-tool-module-syntax">here</a> for more information.
Nevertheless, we strongly recommend you to inspect the default configuration and tailor it to your preferences.

!!! note
    Configuring EasyBuild is also covered in detail in the EasyBuild documentation, see [here](https://easybuild.readthedocs.io/en/latest/Configuration.html).


## Available configuration settings

One of the central policies in the EasyBuild project is to avoid hardcoded settings in the codebase.
While this significantly increases flexibility to configure EasyBuild to your liking, it also results
in a large amount of available configuration settings.

The full list of configuration settings can be consulted via `eb --help`,
which shows the corresponding command line option accompanied by a short description.
At the time of writing, *over 230 different configuration settings* are supported by EasyBuild.

For the sake of this tutorial we will focus on a specific subset of configuration settings and cover
the most prominent and important ones.

!!! note
    We will usually refer to configuration settings using the name as it appears in the output of `eb --help`,
    which may includes dashes (`-`). The leading '`--`' is omitted for the sake of clarity.

    Keep in mind that *every* configuration setting can be defined in 3 different ways,
    see <a href="#consistency-across-configuration-levels">below</a> for more details.

### Overall prefix

*(default: `HOME/.local/easybuild`)*

The `prefix` configuration setting specifies the overall prefix that EasyBuild should use,
which **determines the default value for various other configuration settings**:

* `installpath`: `<prefix>`
* `buildpath`: `<prefix>/build`
* `sourcepath`: `<prefix>/sources`
* `repositorypath` (easyconfigs archive): `<prefix>/ebfiles_repo`
* `containerpath`: `<prefix>/containers`

Here, `<prefix>` represents the value of the `prefix` configuration setting.

If one of the configuration settings affected by `prefix` is defined specifically,
the `prefix` value becomes irrelevant for that specific configuration setting.

### Install path

*(default: `<prefix>`)*

The **location for both the software installation directories and generated module files**
can be controlled via the `installpath` configuration setting.
Software installation directories will be placed in `<installpath>/software`, while
`<installpath>/modules/all` will be used for generated module files.

The `installpath` location is usually set to a directory on a shared filesystem when installing
software for an HPC cluster, such that the installation can be performed on one node 
while being accessible on the whole cluster. Of course, software can also be installed on a local filesystem.
This is particularly useful when testing and evaluating installations.

Separate configuration settings are available for both software and modules locations,
as well as for controlling the `software` and `modules/all` subdirectories.

*We recommend to only change the `installpath` configuration setting to control the location
of software installations and accompanying module files,
such that the software and modules directories are located in the same parent directory
and the default `software` and `modules/all` subdirectories are used.*

### Build path

*(default: `<prefix>/build`)*

For each installation it performs, EasyBuild creates a **separate build directory** where software will be compiled
before installing it. This directory is cleaned up automatically when the installation is successfully completed.
To control the location where these build directories are created, you can use the `buildpath` configuration setting.

Keep in mind that build directories may grow out to several GBs in size during an installation,
and that the commands that run in there can be fairly I/O-intensive since they may involve
manipulating lots of small files. In addition, a build directory that corresponds to a failing installation
is *not* cleaned up automatically, but it will be cleaned up and recycled when the same installation is re-attempted.
Running out of disk space in the location where build directories are created will result in failing
installations.

*It is recommended to use a directory on a local filesystem for `buildpath`, or an in-memory filesystem
like `/dev/shm` (if you have a significant amount of working memory available on your system).
In addition, try to ensure you use a path that does not overlap with other users on the same system.
So set `buildpath` to `/tmp/$USER` or `/dev/shm/$USER`, for example.*

### Source path

*(default: `<prefix>/sources`)*

For most supported software, EasyBuild can **automatically download the source files** required for the installation.
Before trying to download a source file, EasyBuild will first check if it is already present in the source path.

The locations considered by EasyBuild when checking for available source files as well as the location to
stored downloaded source files can be controlled via the ``sourcepath`` configuration setting.

The `sourcepath` value is a colon (`:`) separated list of directory paths.
Each of these paths will be considered in turn when checking for available source files,
until one of them provides the desired source file. Searching for source files is done
based on filename, and a couple of subdirectories are considered.
For example, for a software packagamed '`Example'`, EasyBuild will consider locations like `<sourcepath>/e/Example/`, `<sourcepath>/Example/`, and so on.

The first path listed in `sourcepath` is the location where EasyBuild will store downloaded source files,
organised by software name through subdirectories.

*Make sure you have write permissions to the first path listed in `sourcepath`, so EasyBuild is able
to store downloaded files there. Any additional paths can be read-only for the account running EasyBuild.*

### Easyconfigs archive

*(default: `<prefix>/ebfiles_repo`)*

EasyBuild keeps track of the easyconfig files that were used for installations in the easyconfigs
archive, the location of which is specified by the `repositorypath` configuration setting.

By default the specified path is assumed to be a regular directory, but using a Git repository
as easyconfigs archive is also supported.

More information is available [in the EasyBuild documentation](https://easybuild.readthedocs.io/en/latest/Configuration.html#easyconfigs-repository-repository-repositorypath).

*For the sake of this tutorial we recommend sticking to a regular directory,
and sticking to the default location as a subdirectory of the `prefix` configuration setting.*


### Modules tool & module syntax

*(default: `Lmod` as modules tool, `Lua` as module syntax)*

By default, EasyBuild assumes you are using **[Lmod](https://lmod.readthedocs.io) as modules tool**.
In addition, it will generate module files in [Lua](https://www.lua.org/) syntax, as supported by Lmod.

To diverge from this, you can define the `modules-tool` configuration setting to indicate you
are using a different modules tool, see the output of `eb --avail-modules-tools` for a list of supported
modules tools.
Note that for anything other than Lmod, you *must* make
sure that the actual modules tool binary command is available through `$PATH` (more information
on this [in the EasyBuild documentation](https://easybuild.readthedocs.io/en/latest/Configuration.html#modules-tool-modules-tool)).

If you prefer that EasyBuild generates module files in [Tcl](https://tcl.tk/) syntax, you can instruct
it to do so via the `module-syntax` configuration setting. Note that this is *required* if you are using
a modules tool other than Lmod.

*We recommend using EasyBuild with Lmod as modules tool and Lua as module syntax.*

### Robot search path

*(default: `robot-paths` specifies the location to the easyconfig files included with EasyBuild installation;
dependency resolution is* ***not*** *enabled)*

When EasyBuild needs to locate one or more easyconfig files, it will do so via the **robot search path**.
This applies to both easyconfig files that were specified using only their filename as an argument to the
`eb` command as well as to easyconfigs required to resolve dependencies (more on that later).

To control the robot search path, two configuration settings are available: `robot` and `robot-paths`.
Both accept a colon-separated list of locations to consider when looking for easyconfig files,
with `robot` overriding `robot-paths`.

The key difference between both is that setting `robot` also enables dependency resolution and
hence makes EasyBuild install missing dependencies, alongside
specifying a list of paths to consider when searching for easyconfig files, while defining `robot-paths`
does not have this side effect.
In addition, you can use the `--robot` command line option without specifying any paths to it to only enable dependency resolution.

!!! note
    Keep in mind that when either of the `robot` or `robot-paths` configuration settings are
    defined, the default value corresponding to the location of easyconfigs included with the
    EasyBuild is no longer considered.

    There are ways around this however, which are outside of the scope of this tutorial.

    For more information, [see the EasyBuild documentation](https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html#controlling-robot-search-path).


### Module naming scheme

*(default: `EasyBuildMNS`)*

EasyBuild will use a specific naming scheme for the module files it generates for each of the software installations.
This ensures consistency, regardless of who uses EasyBuild to perform the installation.

Different types of module naming schemes are supported (flat, hierarchical, ...) and you can provide an implementation of
your own custom module naming scheme if desired. A number of different naming schemes are included
with EasyBuild, which you can consult via `eb --avail-module-naming-schemes`).

The default `EasyBuildMNS` module naming scheme roughly corresponds to the filename of easyconfig files,
and consists of the software name followed by a combination of the software version, toolchain and
an optional labels (which corresponds to value of the `versionsuffix` easyconfig parameter):
`<name>/<version><-toolchain><versionsuffix>`.

!!! note
    *Using a different module naming scheme is largely out of scope for this tutorial,
    except when covering [hierarchical module naming schemes](../hmns/README.md).*


## Configuration levels

Configuring EasyBuild can be done in different ways:

* through one or more configuration files;
* via `$EASYBUILD_*` environment variables;
* using `eb` command line options;

Each of the methods corresponds to a *configuration level*.

*Every* configuration setting can be defined via one of these
mechanisms, without exception!

### Configuration level hierarchy

There is a strict **hierarchy between the different configuration levels** supported by EasyBuild.

Settings defined via a *configuration file* only override default values.

A configuration setting that is defined via the corresponding *`$EASYBUILD_*` environment variable*
takes precedence over the value specified in a configuration file (if any).

Finally, values specified through `eb` command line options* **always** win,
regardless of whether the corresponding
configuration setting was already defined some other way, be it via a configuration file or
an environment variable.

For example, let us consider a fictional configuration setting named `-magic`:

* If a value for `magic` is specified in an EasyBuild configuration file,
  then this value will only be used if the corresponding environment variable
  (`$EASYBUILD_MAGIC`).
  is *not* defined **and** if the `---magic` command line option is *not* used;
* If the `$EASYBUILD_MAGIC` environment *is* defined however, then its value
  will be used for the `this-is-magic` configuration setting;
* *Unless* the `--magic` command line option is used,
  since in that case the value provided as an argument there will be used instead;

### Configuration files

*Configuration files* are the most basic way of configuring EasyBuild.
Two types of are supported by EasyBuild: *user-level* and *system-level*
configuration files. The output of `eb --show-default-configfiles` tells you which locations
are considered, and whether any configuration files were found.

EasyBuild configuration files are written in the standard [INI format](https://en.wikipedia.org/wiki/INI_file),
and the configuration settings are grouped into different *sections*.

To create an EasyBuild configuration file, the output of `eb --confighelp` is very useful:
it produces the list of all supported configuration settings which are readily grouped in sections
and with every entry commented out, along with accompanying descriptive comments mentioning the default values,
and in the correct syntax.

*Configuration files are the recommended mechanism to define configuration settings
that should always be in place, regardless of the software you are installing.*

#### EasyBuild configuration files vs easyconfig files

EasyBuild configuration files are sometimes confused with easyconfig files,
due to the similar name. However, these are two entirely different concepts!

EasyBuild configuration files are a way of *configuring the general behaviour of EasyBuild*
across different software installations. They define *configuration settings*,
such as the location where software should be installed, or the syntax that should
be used when generating module files.

An [easyconfig file](../introduction/README.md#easyconfig-files) on the other hand *specifies the details for one particular software installation*.
It does this by defining a set of *easyconfig parameters*, which tell EasyBuild the name and version
of the software to install, which [toolchain](../introduction/README.md#toolchains) and [easyblock](../introduction/README.md#easyblocks) to use, etc.

For each software installation performed by EasyBuild, there is a corresponding easyconfig file.
There typically are only a handful of configuration files used however, for example a system-level
configuration file perhaps combined with a user-level one. Or there may be no configuration files involved 
at all, since EasyBuild can also be configured through other mechanisms: environment variables and command line
options.

Hopefully this helps to avoid the confusion...

### `$EASYBUILD_*` environment variables

A particularly easy way to configure EasyBuild is through *environment variables*.

At startup, EasyBuild will pick up any environment variable of which the name starts with '`EASYBUILD_`'.
For each of these, it will determine the corresponding configuration setting (or exit with an error if
none was found).

Mapping the name of a configuration setting to the name of the corresponding environment variable is straightforward:
use capital letters, replace dashes (`-`) with underscores (`_`), and prefix with `EASYBUILD_`.
For example: the `module-syntax` configuration setting can be specified by defining the `$EASYBUILD_MODULE_SYNTAX` environment variable:

```shell
export EASYBUILD_MODULE_SYNTAX=Tcl
```

*Configuring via environment variables is especially practical for controlling the EasyBuild configuration
in a more dynamic way. For example, you can implement a simple shell script that defines `$EASYBUILD_*`
environment variables based on the current context (user, hostname, other environment variables), and
configure EasyBuild through [sourcing](https://bash.cyberciti.biz/guide/Source_command) it.*

!!! note
    Keep in mind that environment variables are only defined for the shell session you are currently working in.
    If you want to configure EasyBuild through environment variables in a more persistent way,
    you can leverage one of the [shell startup scripts](https://bash.cyberciti.biz/guide/Startup_scripts) (for example `$HOME/.bash_profile` or `$HOME/.bashrc`).

### `eb` command line options

Finally, you can also configure EasyBuild by specifying one or options to the `eb` command.

As mentioned earlier, the values for configuration settings defined this way override the value that
is specified through any other means. So if you want to be sure that a particular configuration setting
is defined the way you want it to be, you can use a command line option.

There are various configuration settings for which it only makes sense to use the command line option.
An example of this is letting the `eb` command print the EasyBuild version (via `eb --version`);
although you could configure EasyBuild to always print its version and then exit whenever the `eb` command is
run, that would be less than useful...

*Command line options are typically used to define configuration settings that are only relevant to
that particular EasyBuild session. One example is doing a test installation into a temporary directory:*

```shell
eb --installpath /tmp/$USER example.eb
```

## Inspecting the current configuration (`--show-config`)

Given the large amount of available configuration settings in EasyBuild and the different configuration levels,
you can easily lose track of exactly how EasyBuild is configured.

Therefore, the `--show-config` command line option is provided
to easily inspect the currently active EasyBuild configuration.

The output includes a sorted list of all configuration settings that are defined to a non-default value,
along with a couple of important ones that are always shown (like `buildpath`, `installpath`, `sourcepath`, and so on).
In addition, it also indicates at which configuration level each setting was defined,
so you can trace down where it was defined if needed.

This is the output produces by `eb --show-config` for the default EasyBuild configuration,
where EasyBuild was installed via `pip install --user`:

```shell
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
buildpath      (D) = /home/example/.local/easybuild/build
containerpath  (D) = /home/example/.local/easybuild/containers
installpath    (D) = /home/example/.local/easybuild
repositorypath (D) = /home/example/.local/easybuild/ebfiles_repo
robot-paths    (D) = /home/example/.local/easybuild/easyconfigs
sourcepath     (D) = /home/example/.local/easybuild/sources
```

As shown here, all configuration settings shown follow the default `prefix` value (`$HOME/.local/easybuild`)
and none of the values diverge from the default value, since all entries are marked with `(D)` for "default value").

Now let us do some basic configuring and inspect the resulting output of `--show-config`:

```shell

$ export EASYBUILD_PREFIX=$HOME/easybuild
$ export EASYBUILD_BUILDPATH=/tmp/$USER
$ eb --installpath=/tmp/$USER --show-config
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
buildpath      (E) = /tmp/example
containerpath  (E) = /home/example/easybuild/containers
installpath    (C) = /tmp/easybuild
packagepath    (E) = /home/example/easybuild/packages
prefix         (E) = /home/example/easybuild
repositorypath (E) = /home/example/easybuild/ebfiles_repo
robot-paths    (D) = /home/example/.local/easybuild/easyconfigs
sourcepath     (E) = /home/example/easybuild/sources
```

The output indicates that the `installpath` setting was specified through a command line option (indicated
with '`(C)`'), that the `robot-paths` setting still has the default values, and that all other configuration
settings were specified via an environment variable (some of which indirectly through the `prefix` value).

---

!!! warning
    **Make sure you have EasyBuild properly configured before you proceed with the rest of the tutorial!**

    We recommend using the following configuration (unless otherwise specified in the examples/exercises):

    ```shell
    export EASYBUILD_PREFIX=$HOME/easybuild
    export EASYBUILD_BUILDPATH=/tmp/$USER
    ```
