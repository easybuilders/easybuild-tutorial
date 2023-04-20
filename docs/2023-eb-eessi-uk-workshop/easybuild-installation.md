# Installing EasyBuild

Before deep diving into the wonderful world of EasyBuild and getting your hands dirty with
the hands on exercises coming up in this tutorial, you will need to install EasyBuild.

In this section we outline three different ways of doing this, and also the things you should pay attention to.
By the end of this section, you will have a functional EasyBuild installation that you can use
for the remainder of this tutorial.

!!! summary

    * *Requirements*:
        * Linux as operating system
        * Python 2.7 or 3.5+ (Python 3.6 is recommended)
        * An environment modules tool (Lmod is recommended)
    * *Installation methods*:
        * [``pip install easybuild``](#method-1-using-pip)
        * [installing EasyBuild with EasyBuild](#method-2-bootstrapping-easybuild)
        * [development setup](#method-3-development-setup)
    * Verify EasyBuild installation by running `eb` commands.

---

## Requirements

### Linux

The main target platform for EasyBuild is *Linux*, since it is heavily focused on installing software
on HPC system where Linux is dominant operating system (to the point where
[100% of the current Top500 list of supercomputers are running Linux](https://www.top500.org/statistics/list)).

EasyBuild is also compatible with *macOS*, but the included easyconfig files are heavily focused
on Linux so most software installations supported by EasyBuild won't work out-of-the-box on macOS.
You can still use the EasyBuild command line interface on macOS for other tasks though,
such as development or contributing back to the project.

### Python

EasyBuild is implemented in Python, and is **compatible with both Python 2.7 and Python 3.5+**
(that is, Python 3.5 or a newer version of Python 3).

In the near future compatibility with Python 2.7 and 3.5 will be dropped in EasyBuild,
so we recommend using Python 3.6, or newer.

To check which Python version you have, use:

```shell
python -V
```

!!! note

    It is possible that the ``python`` command is not available, which will trigger an error like:

    ```
    -bash: python: command not found
    ```

    If that is the case, consider using the ``python3`` command (or similar) instead.

*No additional Python packages are required by EasyBuild*, the ones that come with the standard
Python distribution are sufficient. Some additional Python packages *can* be leveraged for specific features.
More on that later.

### Environment modules tool

**An *environment modules tool* is required for using EasyBuild.**

We strongly recommend using [Lmod](https://lmod.readthedocs.io), a Lua-based modern environment
modules implementation and the most commonly used environment modules tool in the EasyBuild community.
Other implementations, like the original Tcl-based one, are also supported.

To check if you have a modules tool installed, use:

```
module --version
```

If this produces output that starts with something like "`Modules based on Lua: Version 8.7.23`" you have Lmod installed,
which is the default modules tool used by EasyBuild, and you are all set for installing and using EasyBuild.
Any sufficiently recent Lmod version (8.x or even 7.x) should be fine.

If you see output that starts with a line like "`VERSION=3.2.10`" or "`Modules Release 5.2.0`",
you have the original Tcl-based environment modules tool installed and
[*EasyBuild will need to be configured to use it after installation*](https://docs.easybuild.io/configuration/#modules_tool).

If the `module` function is not defined you do not have a modules tool installed,
or your environment is not properly set up to use it. In this case,
please refer to the EasyBuild documentation [here](https://docs.easybuild.io/installation/#required_modules_tool) for more information.

---

## EasyBuild as a Python package

EasyBuild consists of a number of interdependent Python packages,
and is available via both GitHub at <https://github.com/easybuilders>,
as well as via the standard Python Package Index (PyPI) at
<https://pypi.org/project/easybuild">.

As you may be aware the Python packaging ecosystem is bit convoluted,
which is reflected in the many different ways in which you can install a Python package.
In addition, EasyBuild is packaged in 3 components (framework, easyblocks, easyconfigs)
which slightly complicates the installation.

<div align="center"><a href="https://xkcd.com/1987/"><img src="https://imgs.xkcd.com/comics/python_environment.png" width="400px"></a></div>

Nevertheless, you don't need to be a rocket scientist to install EasyBuild (and even if you are,
that's OK too), so don't worry.

You can install EasyBuild just like you can install any other Python software that is released
via the standard *Python Package Index* (PyPI), through one of the standard Python installation tools
(like `pip`, `virtualenv`, `pipenv`, ...).
And since EasyBuild is a software installation tool in its own right, we actually have a couple
of additional tricks up our sleeve!

### Python 2 or Python 3?

For EasyBuild it does not matter whether you install it on top of Python 2 or Python 3. The functionality
provided is identical.
However, <a href="https://www.python.org/doc/sunset-python-2/">Python 2 is end-of-life</a> and
compatibility with Python 2.7 and 3.5 will be removed soon in EasyBuild, so we strongly recommend
using Python 3 if you have the choice.

By default EasyBuild will use the `python` command to run,
but you <a href="#setting-eb_python">can control this if needed via ``$EB_PYTHON``</a>.


## Installing EasyBuild

We present three methods for installing EasyBuild.
It is up to you which one you prefer, each result in a fully functional EasyBuild installation.

Time to get your hands dirty!

* [Method 1: Using ``pip``](#method-1-using-pip)
* [Method 2: installing EasyBuild with EasyBuild](#method-2-installing-easybuild-with-easybuild)
* [Method 3: Development setup](#method-3-development-setup)

---

### Method 1: Using `pip`

Since EasyBuild is released as a [Python package on PyPI](https://pypi.org/project/easybuild)
you can install it using `pip`, the most commonly used tool for installing Python packages.

You may need to take additional steps after the installation, depending on the exact installation command.

!!! note
    There are various other ways of installing Python packages, which we won't cover here.
    If you are familiar with other tools like `virtualenv` or `pipenv`, feel free to use those
    instead to install EasyBuild.

#### Running `pip install`

Installing EasyBuild with `pip` is as simple as running the following command:

```shell
pip install easybuild
```

However, you may need to slightly change this command depending on the context and your personal preferences:

* To install EasyBuild *system-wide*, you can use `sudo` (if you have admin privileges):
  ```shell
  sudo pip install easybuild
  ```

* To install EasyBuild *in your personal home directory*, you can use the `--user` option:
  ```shell
  pip install --user easybuild
  ```
  This will result in an EasyBuild installation in `$HOME/.local/`.

* To install EasyBuild in a *specific directory* you can use the `--prefix` option:
  ```shell
  pip install --prefix _PREFIX_ easybuild
  ```
  In this command, you should replace '`_PREFIX_`' with the location where you want to have EasyBuild installed
  (for example, `$HOME/tools` or `/tmp/$USER`).

#### `pip` vs `pip3`

On systems where both Python 2 and Python 3 are installed you may also have different `pip` commands
available. Or maybe `pip` is not available at all, and only "versioned" `pip` commands like `pip3` are
available.

If you (only) have `pip3` available, you can replace `pip` with `pip3` in any of the `pip install` commands
above.

If you want to ensure that you are using the ``pip`` installation that corresponds to the Python 3 installation
that you intend to use, you can use ``python3 -m pip`` rather than ``pip3``.

#### Updating your environment

If you used the `--user` or `--prefix` option in the `pip install` command,
or if you installed EasyBuild with a `pip` version that does not correspond
to your default Python installation,
you will need to update your environment to make EasyBuild ready for use.
This is not required if you did a system-wide installation in a standard location with the default Python version.

!!! note
    Keep in mind that you will have to make these environment changes again if you start a new shell session.
    To avoid this, you can update the `.bashrc` shell startup script in your home directory.

#### Updating ``$PATH``

Update the `$PATH` environment variable to make sure the `eb` command is available:
```shell

export PATH=_PREFIX_/bin:$PATH
```
**Replace '`_PREFIX_`' in this command** with the directory path where EasyBuild was installed into
(use `$HOME/.local` if you used `pip install --user`).

This is not required if you installed EasyBuild in a standard system location.

You can check with "`which eb`" or "`command -v eb`" to determine whether or not you need to update
the ``$PATH`` environment variable.

#### Updating ``$PYTHONPATH``

If you installed EasyBuild to a non-standard location using `pip install --prefix`,
you also need to update the Python search path environment variable
[`$PYTHONPATH`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONPATH) to instruct Python where
it can find the EasyBuild Python packages.

This is not required if you used the `--user` option, since Python will automatically consider
`$HOME/.local` when searching for installed Python packages, or if you installed EasyBuild in a standard
system-wide location.

Update `$PYTHONPATH` by running a command like:

```shell

export PYTHONPATH=_PREFIX_/lib/pythonX.Y/site-packages:$PYTHONPATH
```

Here, you need to replace the `X` and `Y` with the major and minor version of your Python installation,
which you can determine by running `python -V`.
For example, if you are using Python 3.6, make sure you are using `/python3.6/` in the command to update `$PYTHONPATH`.

And of course, you again need to **replace '`_PREFIX_`'** with the installation prefix where EasyBuild was installed
into.

For example:

```shell
# update $PYTHONPATH if EasyBuild was installed in $HOME/tools with Python 3.6
export PYTHONPATH=$HOME/tools/lib/python3.6/site-packages:$PYTHONPATH
```

#### Setting ``$EB_PYTHON``

If you want to control which Python version is used to run EasyBuild,
you can specify the name or the full path to the `python` command that should be used by the `eb` command
via the `$EB_PYTHON` environment variable.

This may be required when you installing EasyBuild with a version of `pip` that does not correspond
with the default Python version.

For example, to ensure that the `eb` command uses `python3.6`:

```shell
export EB_PYTHON=python3.6
```

#### Setting ``$EB_VERBOSE``

To determine which `python` commands are being considered by the `eb` command,
you can define the `$EB_VERBOSE` environment variable. For example:

```shell
$ EB_VERBOSE=1 eb --version
>> Considering 'python3'...
>> 'python3' version: 3.6.8, which matches Python 3 version requirement (>= 3.5)
>> 'python3' is able to import 'easybuild.main', so retaining it
>> Selected Python command: python3 (/usr/bin/python3)
>> python3 -m easybuild.main --version
This is EasyBuild 4.7.1 (framework: 4.7.1, easyblocks: 4.7.1) on host example
```

---

### Method 2: Installing EasyBuild with EasyBuild

!!! note
    This section covers an alternative method for installing EasyBuild.

    If you have installed EasyBuild through ``pip`` already,
    you can [skip ahead to the next section](#verifying-the-installation).

If you prefer having EasyBuild available through an environment module file,
you can consider installing EasyBuild with EasyBuild. This can be done in 3 steps:

* Step 1: Installing EasyBuild with ``pip`` into a temporary location (only needed if EasyBuild is not installed yet)
* Step 2: Using EasyBuild to install EasyBuild as a module
* Step 3: Loading the EasyBuild module


#### Step 1: Installing EasyBuild into a temporary location with pip

If you don't have EasyBuild installed yet, you need to install it in a temporary location first.
The recommended way of doing this is [using ``pip``](#method-1-using-pip).

For example, to install EasyBuild into a subdirectory `/tmp/$USER` using Python 3.6:

```shell
# pick installation prefix, and install EasyBuild into it
export EB_TMPDIR=/tmp/$USER/eb_tmp
python3.6 -m pip install --ignore-installed --prefix $EB_TMPDIR easybuild
```

```shell
# update environment to use this temporary EasyBuild installation
export PATH=$EB_TMPDIR/bin:$PATH
export PYTHONPATH=$EB_TMPDIR/lib*/python3.6/site-packages/:$PYTHONPATH
export EB_PYTHON=python3.6
```

#### Step 2: Using EasyBuild to install EasyBuild

Once you have a working (recent) temporary EasyBuild installation, you can use it to
install EasyBuild as a module. Usually this is done in the location where you would
like to install other software too.

You can use the ``eb --install-latest-eb-release`` command for this,
combined with the ``--prefix`` option to control which directories are used by EasyBuild for the installation.

For example, to install the latest version of EasyBuild as a module into ``$HOME/easybuild``:

```shell
eb --install-latest-eb-release --prefix $HOME/easybuild
```

!!! note
    You may see a harmless deprecation warning popping up when performing this installation, just ignore it.

#### Step 3: Loading the EasyBuild module

Once step 2 is completed, you should be able to load the module that was generated alongside
the EasyBuild installation. You will need to do this every time you start a new shell session
in which you want to use EasyBuild.

First, make the module available by running the following command (which will update the module search path
environment variable `$MODULEPATH`):

```shell

module use _PREFIX_/modules/all
```

**Replace '`_PREFIX_`'** with the path to the directory that you used when running step 2
(for example, ``$HOME/easybuild``).

Then, load the `EasyBuild` module to update your current shell environment and make EasyBuild available for use:

```shell

module load EasyBuild
```

Note that in this case, we don't need to make any changes to our environment for EasyBuild to work correctly.
The environment module file that was generated by EasyBuild specifies all changes that need to be made,
which includes making sure that the right Python version is used by the `eb` command.

### Method 3: Development setup

If you are planning to make changes to EasyBuild, or if you prefer using the latest *bleeding edge*
version of EasyBuild that is being developed, you can consider *cloning* the 3 main EasyBuild repositories
from GitHub, and updating your environment to run EasyBuild from there.

This can be done as follows (into ``$HOME/easybuild``):

```shell
mkdir -p $HOME/easybuild
cd $HOME/easybuild
```

```shell
# clone EasyBuild repositories from GitHub
git clone https://github.com/easybuilders/easybuild-framework.git
git clone https://github.com/easybuilders/easybuild-easyblocks.git
git clone https://github.com/easybuilders/easybuild-easyconfigs.git
```
```shell
# update environment for running EasyBuild from there
export PATH=$HOME/easybuild/easybuild-framework:$PATH
export PYTHONPATH=$HOME/easybuild/easybuild-framework:$HOME/easybuild/easybuild-easyblocks:$HOME/easybuild/easybuild-easyconfigs:$PYTHONPATH

# control which Python command is used to run EasyBuild
export EB_PYTHON=python3
```


## Verifying the installation

Regardless of how EasyBuild was installed, you can now run a couple of basic commands to verify the installation:

#### Checking the version

To check which EasyBuild version you have installed, run:

```shell

eb --version
```

The output should match with the [latest EasyBuild version](https://pypi.org/project/easybuild/), unless you
installed the development version from method 3 above where the version string will include `dev` and git
hashes for the framework and easyblock repositories.


#### Consulting the help output

You can consult the help output of the `eb` command, which produces a long list of available options
along with a short informative message.

```shell
eb --help
```

#### Showing the active EasyBuild configuration

To inspect the current EasyBuild configuration, you can use this command:

```shell
eb --show-config
```

This should tell you that EasyBuild (ab)uses `$HOME/.local/easybuild` as a default location.
More on configuring EasyBuild in the [next part of the tutorial](easybuild-configuration.md).

#### System information

You can let EasyBuild collect and print some information about the
system you are using it on (OS, CPU, Python, etc.) using this command:

```shell
eb --show-system-info
```

## Updating EasyBuild

Before we wrap up here, a brief word about updating EasyBuild.

Once you have EasyBuild installed, the easiest way to update to a newer version is by instructing EasyBuild
to install the latest available version as a module:

```

eb --install-latest-eb-release
```

This will result in a *new* EasyBuild installation, which is entirely separate from the EasyBuild installation
you are currently using (so it is *not* an in-place update).
The location where this new EasyBuild version will be installed is determined by the active
EasyBuild configuration.

If you have installed EasyBuild through ``pip``, and you prefer updating that installation (in-place),
you can use ``pip install --upgrade easybuild`` (perhaps using additional options like ``--user`` or ``--prefix``,
depending on how you installed EasyBuild with ``pip`` originally).

---

## Exercise

Install EasyBuild in your home directory.

Make sure that the EasyBuild installation uses the `python3` command to run,
rather than the standard `python` command.

Choose your own adventure, or try all these installation methods!

* Install EasyBuild with `pip` (or another very similar command...) using either the `--user` or `--prefix` option;
* Perform a (manual) "bootstrap" installation into `$HOME/easybuild`, as outlined in [installation method 2](#step-2-using-easybuild-to-install-easybuild);
* Set up a development installation;

Check that the installation works by running the verification commands outlined
[above](#verifying-the-installation).

---

**Make sure you have a working EasyBuild installation before proceeding
with the rest of the tutorial!**

---

[*next: Configuring EasyBuild*](easybuild-configuration.md) - [*(back to overview page)*](index.md)
