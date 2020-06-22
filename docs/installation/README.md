# Installation

Before deep diving into the wonderful world of EasyBuild and getting your hands dirty with
the hands on exercises coming up in this tutorial, you will need to install EasyBuild.

In this section we outline a couple of different ways of doing this, and also the things you should pay attention to.
By the end, you will have a functional EasyBuild installation that you can use
for the remainder of this tutorial.

!!! summary

    * <a href="#requirements">requirements</a>: Linux, Python 2.7 or 3.5+, environment modules tool (Lmod is recommended)
    * installation methods:
        * <a href=#method-1-using-pip-recommended>``pip install easybuild``</a>
        * <a href="#method-2-bootstrapping-easybuild">bootstrapping EasyBuild</a>
    * verify EasyBuild installation using `eb --version` and `eb --help`


## Requirements

### Linux

The main target platform for EasyBuild is *Linux*, since it is heavily focused on installing software
on HPC system where Linux is dominant operating system (to the point where <a href="https://www.top500.org/statistics/list/">100% of the current Top500 list of supercomputers are running Linux</a>).

EasyBuild is also compatible with *macOS*, but the included easyconfig files are heavily focused
on Linux so most software installations supported by EasyBuild won't work out-of-the-box on macOS.
You can still use the EasyBuild command line interface on macOS for other tasks though,
like contributing back to the project.

### Python

EasyBuild is implemented in Python, and is **compatible with both Python 2.7 and Python 3.5+**
(that is, Python 3.5 or a newer version of Python 3).

To check which Python version you have, use:

```shell
python -V
```

*No additional Python packages are required by EasyBuild*, the ones that come with the standard
Python distribution are sufficient. Some additional Python packages *can* be leveraged for specific features.
More on that later.

### Environment modules tool

**An *environment modules tool* is required for using EasyBuild.**

We strongly recommend using [Lmod](https://lmod.readthedocs.io), a Lua-based modern environment
modules implementation and the most commonly used modules tool in the EasyBuild community.
Other implementations, like the original Tcl-based one, are also supported.

To check if you have a modules tool installed, use:

```
module --version
```

If this produces output that starts with something like "`Modules based on Lua: Version 8.2.5`" you have Lmod installed,
which is the default modules tool used by EasyBuild, and you are all set for installing and using EasyBuild.
Any sufficiently recent Lmod version (8.x or even 7.x) should be fine. 

If you see output that starts with a line like "`VERSION=3.2.10`" or "`Modules Release 4.5.0`",
you have the original Tcl-based environment modules tool installed
and <a href="https://easybuild.readthedocs.io/en/latest/Configuration.html#modules-tool-modules-tool">*EasyBuild will need to be configured to use it after installation*</a>.

If the `module` function is not defined either you do not have a modules tool installed
or your environment is not properly set up to use it. In this case,
please refer to the EasyBuild documentation <a href="https://easybuild.readthedocs.io/en/latest/Installation.html#required-modules-tool">here</a> for more information.


## EasyBuild as a Python package

EasyBuild consists of a number of interdependent Python packages,
and is available via both GitHub at <a href="https://github.com/easybuilders">https://github.com/easybuilders</a>,
as well as via the standard Python Package Index (PyPI) at
<a href="https://pypi.org/project/easybuild/">https://pypi.org/project/easybuild</a>.

As you may be aware the Python packaging ecosystem is bit convoluted,
which is reflected in the many different ways in which you can install a Python package.
In addition, EasyBuild is packaged in 3 components (framework, easyblocks, easyconfigs)
which slightly complicates the installation.

<div align="center"><a href="https://xkcd.com/1987/"><img src="https://imgs.xkcd.com/comics/python_environment.png" width="350px"></a></div>

Nevertheless, you don't need to be a rocket scientist to install EasyBuild (and even if you are,
that's OK too), so don't worry.

You can install EasyBuild just like you can install any other Python software that is released
via the standard *Python Package Index* (PyPI), through one of the standard Python installation tools
(like `pip`, `virtualenv`, `pipenv`, ...).
And since EasyBuild is a software installation tool in its own right, we actually have a couple
of additional tricks up our sleeve!

#### Python 2 or Python 3?

For EasyBuild it does not matter whether you install it on top of Python 2 or Python 3. The functionality
provided is identical.
However, since <a href="https://www.python.org/doc/sunset-python-2/">Python 2 is end-of-life</a>,
we strongly recommend using Python 3 if you have the choice.

By default EasyBuild will use the `python` command to run, but you can control
this if needed.
For more information, see <a href="https://easybuild.readthedocs.io/en/latest/Python-2-3-compatibility.html">
the EasyBuild documentation</a>.


## Installing EasyBuild

We present two methods for installing EasyBuild.
It is up to you which one you prefer, both result a fully functional EasyBuild installation.

Time to get your hands dirty!


### Method 1: Using `pip` *(recommended)*

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

#### Updating your environment

If you used the `--user` or `--prefix` option in the `pip install` command, 
you will need to update your environment to make EasyBuild ready for use.
This is not required if you did a system-wide installation in a standard location.

!!! note
    Keep in mind that you will have to make these environment changes again if you start a new shell session.
    To avoid this, you can update one of the shell startup scripts in your home directory (`.bashrc` for example).

**`$PATH`**

Update the `$PATH` environment variable to make sure the `eb` command is available:
```shell

export PATH=_PREFIX_/bin:$PATH
```
**Replace '`_PREFIX_`' in this command** with the directory path where EasyBuild was installed into
(use `$HOME/.local` if you used `pip install --user`).

**`$PYTHONPATH`**

If you installed EasyBuild to a non-standard location using `pip install --prefix`,
you also need to update the Python search path environment variable `$PYTHONPATH` to instruct Python where
it can find the EasyBuild Python packages.
This is not required if you used the `--user` option, since Python will automatically consider
`$HOME/.local` when searching for installed Python packages.

Update `$PYTHONPATH` by running a command like:

```shell

export PYTHONPATH=_PREFIX_/lib/pythonX.Y/site-packages:$PYTHONPATH
```

Here, you need to replace the `X` and `Y` with the major and minor version of your Python installation,
which you can determine by running `python -V`.
For example, if you are using Python 2.7, make sure you are using '`python2.7`' in the command to update `$PYTHONPATH`.

And of course, you again need to **replace '`_PREFIX_`'** with the installation prefix where EasyBuild was installed
into.

For example:

```shell
# update $PYTHONPATH if EasyBuild was installed in $HOME/tools with Python 3.6
export PYTHONPATH=$HOME/tools/lib/python3.6/site-packages:$PYTHONPATH
```

**`$EB_PYTHON` and `$EB_VERBOSE`**

If you want to control which Python version is used to run EasyBuild,
you can specify the name or the full path to the `python` command that should be used by the `eb` command
via the `$EB_PYTHON` environment variable.

For example, to ensure that `eb` uses `python3`:

```shell
export EB_PYTHON=python3
```

To get a better view on which `python` commands are being considered by the `eb` command,
you can (temporarily) define the `$EB_VERBOSE` environment variable. For example:

```shell
$ EB_VERBOSE=1 eb --version
>> Considering 'python3'...
>> 'python3' version: 3.6.8, which matches Python 3 version requirement (>= 3.5)
>> Selected Python command: python3 (/usr/bin/python3)
>> python3 -m easybuild.main --version
This is EasyBuild 4.2.1 (framework: 4.2.1, easyblocks: 4.2.1) on host example
```


### Method 2: Bootstrapping EasyBuild

!!! note
    This section covers an alternative installation method.

    If you already have EasyBuild installed, you can <a href="#verifying-the-installation">skip ahead to the next section</a>.

If `pip` is not available or if the installation with `pip` is not working out for some reason,
you can resort to using the [*bootstrapping* procedure for installing EasyBuild](https://easybuild.readthedocs.io/en/latest/Installation.html#bootstrapping-easybuild).

In essence, the bootstrap script installs EasyBuild into a temporary location and then uses this
temporary EasyBuild installation to install EasyBuild into the specified directory and provide a module for it.



#### Step 1: Downloading the bootstrap script

First, download the latest version of the EasyBuild bootstrap script from GitHub.

A common way to do this is by running this `curl` command:

```shell

curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py
```

#### Step 2: Running the bootstrap script

To install EasyBuild using the bootstrap script simply run it using the `python` command
and specify the installation prefix as an argument:

```shell

python bootstrap_eb.py _PREFIX_
```

**Replace '`_PREFIX_`'** with the location where you want to have EasyBuild installed (for example, `$HOME/tools`
or `/tmp/$USER`).

#### Step 3: Loading the EasyBuild module

Once the bootstrap procedure completed, you should be able to load the module that was generated alongside
the EasyBuild installation. You will need to do this every time you start a new shell session.

First, make the module available by running the following command (which will update the module search path
environment variable `$MODULEPATH`):

```shell

module use _PREFIX_/modules/all
```

**Replace '`_PREFIX_`'** in the same way as you did when running the bootstrap script.

Then, load the `EasyBuild` module to update your environment and make EasyBuild available for use:

```shell

module load EasyBuild
```

!!! note
    No output will be generated by either of these `module` commands. That is expected behaviour and completely normal.

## Verifying the installation

Regardless of how EasyBuild was installed, you can now run a couple of basic commands to verify the installation:

#### Checking the version

To check which EasyBuild version you have installed, run:

```shell

eb --version
```

The output should match with the <a href="https://pypi.org/project/easybuild/">latest EasyBuild version</a>.


#### Consulting the help output

You can consult the help output of the `eb` command, which produces a long list of available options
along with a short informative message.

```shell

eb --help
```

#### Showing the default EasyBuild configuration

To inspect the current EasyBuild configuration, you can use this command:

```shell

eb --show-config
```

This should tell you that EasyBuild (ab)uses `$HOME/.local/easybuild` as a default location.
More on configuring EasyBuild in the next part of the tutorial.

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

---

!!! warning
    **Make sure you have EasyBuild installed before you proceed with the rest of the tutorial!**
