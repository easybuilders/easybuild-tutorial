# Basic usage

Now we have installed and configured EasyBuild, we can start using it for what it is intended for:
getting scientific software installed without breaking a sweat or having to resist the urge to
shout out four-letter words.

We will look at the high-level workflow first, and then cover each aspect in more detail.

We will wrap things up by stepping through an example and offering a couple of exercises that
will help to make you more familiar with the EasyBuild command line interface.

## Workflow

Installing software with EasyBuild is as easy (hah!) as specifying to the **`eb` command** what we
want to install, and then sitting back to enjoy a coffee or tea (or whatever beverage you prefer).

This is typically done by **specifying the name of one or more easyconfig files**, usually in combination
with the `--robot` option to enable dependency resolution.

It is recommended to assess the current situation before letting EasyBuild install the software,
to check which **dependencies** are already installed and which are still missing. In addition,
you may want to inspect the specifics of the **installation procedure** that will be performed by EasyBuild
and ensure that the configuration option are what you would expect, for example.

## Specifying easyconfigs

Letting EasyBuild know what should be installed can be done by specifying one or more easyconfig files,
which is also the most common way. Alternative methods like using the `--software-name` option won't be
covered in this tutorial, since they are not commonly used. We will briefly cover how to install
easyconfig files straight from a GitHub pull request later though
(see [here](../contributing#using-easyconfigs-from-a-pr)).

Arguments passed to the `eb` command, being anything that is *not* an option (which starts with `-` or `--`) or
is a value for a preceding option, are assumed to refer to easyconfig files. These could be:

* the *(absolute or relative) path* to an easyconfig file;
* the *name* of an easyconfig file;
* the path to a *directory*;

Specified paths must of course point to an existing file; if not, EasyBuild will print an appropriate error message:

```shell
$ eb /tmp/does_not_exist.eb
ERROR: Can't find path /tmp/does_not_exist.eb
```

When only the *name* of an easyconfig file is specified, EasyBuild will automatically try and locate it.
First, it will consider the *current directory*. If no file with the specified name is found,
then EasyBuild will search for the easyconfig file in the [robot search path](../configuration#robot-search-path).

If the path to an existing *directory* is provided, EasyBuild will walk through the entire directory
(including all subdirectories), retain all files of which the name ends with '`.eb`', and use these
as easyconfig files.


#### Example

Suppose we have the current situation in our home directory:

* two (easyconfig) files named `example1` and `example2`;
* a subdirectory named `some_deps`, which has two easyconfig files `dep1.eb` and `dep2.eb`
  alongside a text file named `list.txt`;
* a subdirectory named `more_deps` located *in* the `some_deps` subdirectory,
  which contains another easyconfig file `dep3.eb`;

Or, visually represented:

```shell
example1
example2
some_deps/
|-- dep1.eb
|-- dep2.eb
|-- list.txt
|-- more_deps/
    |-- dep3.eb
```

In this context, we run the following EasyBuild command from our home directory:

```shell
eb bzip2-1.0.6.eb example1 $HOME/example2 deps
```

EasyBuild will interpret each of these arguments as follows:

* `bzip2-1.0.6.eb` is the name of an easyconfig file to locate via the robot search path
  (since it does not exist in the current directory);
* `example1` is the name of a file in the current directory, so it can be used directly;
* likewise, `$HOME/example2` specifies the full path to an existing file, which can be used directly;
* `some_deps` is the relative path to an existing directory, so EasyBuild will scan it and find three
  easyconfig files: `some_deps/dep1.eb`, `some_deps/dep2.eb` and `some_deps/more_deps/dep3.eb`,
  ignoring the `list.txt` file since its name does not end with '`.eb`';

### Easyconfig filenames

Note that EasyBuild does not seem to care how easyconfig files are named, to some extent (the '`.eb`'
extension does matter w.r.t. easyconfig files being picked up in subdirectories).

That is correct with respect to the arguments passed to the `eb` command,
but as we will learn soon the name of easyconfig files *does* matter a lot when EasyBuild
needs to locate easyconfig files that can be used to resolve a specified dependency
(see [here](#enabling-dependency-resolution)).

This explains why easyconfig files usually follow a very specific naming scheme,
which basically corresponds with `<name>-<version>-<toolchain><versionsuffix>.eb`,
where:

* `<name>` represents the software name;
* `<version>` represents the software version;
* `<toolchain>` represents the toolchain label, consisting of the toolchain name and version separated with a dash
  (`-`);
* `<versionsuffix>` represents the value of the `versionsuffix` easyconfig parameter,
  which is sometimes used to distinguish multiple variants of particular software installations
  (and is empty by default);

The `-<toolchain>` part is omitted when the [`system` toolchain](../introduction#system-toolchain) is used.

### Searching for easyconfigs


The easyconfig 
`-S`, `--search`

## Inspecting easyconfigs

`--show-ec`

## Checking dependencies

`--dry-run`/`-D`, `--missing`/`-M`

## Performing a dry run

`--extended-dry-run`/`-x`

## Installing software

### Enabling dependency resolution

### Trace output

`--trace`

## Using installed software

## Stacking software

## Example

## Hands-on exercises

No peeking!

***Exercise 4.1**** - Searching easyconfigs*

See if EasyBuild provides any easyconfig files for TensorFlow 2.2.0.

??? success "(click to show solution)"
    ```shell
    eb --search TensorFlow-2.2.0
    ```

***Exercise 4.2****- Checking dependencies*

Check which dependencies are missing to install PETSc 3.12.4 with the `foss/2020a` toolchain.

??? success "(click to show solution)"
    ```shell
    eb --search 'PETSc-3.12.4.*foss-2020a'
    ```
    ```shell
    eb PETSc-3.12.4-foss-2020a-Python-3.8.2.eb --missing
    ```

***Exercise 4.3****- Performing a dry run*

Inspect the installation procedure for `GSL-2.6-GCC-9.3.0.eb` by performing a dry run.

Which binaries will EasyBuild check for to sanity check the installation?

??? success "(click to show solution)"
    ```shell
    eb -x GSL-2.6-GCC-9.3.0.eb
    ```

    Binaries: `gsl-config`, `gsl-histogram`, `gsl-randist`.

***Exercise 4.4****- Installing software*

Install the `h5py` Python package and all missing dependencies for Python 3.8.2,
into `/tmp/$USER/easybuild` and leveraging already install software from `/easybuild`.

Enable trace output so you can see which parts of the installation take a while.

??? success "(click to show solution)"
    ```shell
    eb --search 'h5py.*Python-3.8.2'
    ```
    ```shell
    module use /easybuild/modules/all
    ```
    ```shell
    eb h5py-2.10.0-foss-2020a-Python-3.8.2.eb --missing
    ```
    ```shell
    eb h5py-2.10.0-foss-2020a-Python-3.8.2.eb --robot --installpath /tmp/$USER/easybuild
    ```

***Exercise 4.5****- Using installed software*

Using the `h5py` installation from the previous exercise to create an empty HDF5 file,
using the following Python statements:

```python
import h5py
f = h5py.File("mytestfile.hdf5", "w")
f.close()
```

Check the resulting file using the `h5stat` command.

??? success "(click to show solution)"
    ```shell
    module use /tmp/$USER/easybuild/modules/all
    ```
    ```shell
    module avail h5py
    ```
    ```shell
    module load h5py/2.10.0-foss-2020a-Python-3.8.2
    ```
    ```shell
    python -c 'import h5py; f = h5py.File("empty.hdf5", "w"); f.close()'
    ```
    ```shell
    h5stat empty.hdf5
    ```
