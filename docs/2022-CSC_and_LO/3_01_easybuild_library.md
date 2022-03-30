# Using EasyBuild as a library

*[[back: Configuring EasyBuild]](1_07_configuration.md)*

---

You can use EasyBuild as a Python library and implement a script to automate a particular task.

All the functionality provided by the EasyBuild framework can be leveraged,
so you only have to glue things together and add the missing pieces.


## Setting up the EasyBuild configuration

Before you call any of the functions provided by the EasyBuild framework,
you should initialize EasyBuild by **setting up the configuration**.
Some of the EasyBuild framework functions assume that EasyBuild has been initialized properly,
and calling them without doing so will result in errors.

To set up the EasyBuild configuration, you should call the ``set_up_configuration`` function
that is provided by the ``easybuild.tools.options`` module.

This function takes a couple of optional arguments that are useful in the context of
a Python script that uses EasyBuild as a library:

* Via ``args`` you can provide a list of command line arguments that should be passed to the option parser.
  By default, the standard command line arguments are picked up via ``sys.args``, which may not be what you want.
* By passing ``silent=True`` you can specify that the ``set_up_configuration`` function should not print
  anything when it is called. By default, it will print the location to the temporary EasyBuild log file.

### Cleaning up the temporary directory

When EasyBuild is configured, a temporary directory specific to that EasyBuild session will be created automatically.
You should clean up that directory, especially if you will be creating temporary files, or if the script will be run
often.

Note that cleaning up the temporary directory implies removes the temporary log files,
so you probably only want to do this if no errors occurred.

### Minimal example script

Here is a minimal (and pretty useless) example Python script, which sets up the EasyBuild configuration
and cleans up the temporary directory:

```python
#!/usr/bin/env python3
from easybuild.tools.filetools import remove_dir
from easybuild.tools.options import set_up_configuration

opts, _ = set_up_configuration(args=[], silent=True)

remove_dir(opts.tmpdir)
```


## Example use cases

Once the EasyBuild configuration has been set up, the functions provided by the EasyBuild framework
can be called from a Python script (or directly from the Python interpreter).

A full overview of all functions is available via the [EasyBuild API documentation](https://docs.easybuild.io/en/latest/api/easybuild.html).

We highlight a couple commonly used functions in the sections below.

### File operations

The [``easybuild.tools.filetools``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html)
module provides a bunch of functions for performing file operations.

That includes straightforward things like reading, writing, and copying files
(see [``read_file``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.read_file), [``write_file``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.write_file), [``copy_file``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.copy_file)), but also more specific functionality like applying a patch file ([``apply_patch``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.apply_patch)),
computing different types of checksums for a file ([``compute_checksum``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.compute_checksum)), and downloading files
([``download_file``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html#easybuild.tools.filetools.download_file)).

Here is a trivial example where we download a file from a specified URL to a temporary directory,
compute the SHA256 checksum, and then copy the downloaded file to the current working directory:

```python
#!/usr/bin/env python3
import os
import sys
import tempfile

from easybuild.tools.filetools import download_file, compute_checksum, copy_file, remove_dir
from easybuild.tools.options import set_up_configuration

url = sys.argv[1]

opts, _ = set_up_configuration()

fn = os.path.basename(url)
tmp_path = os.path.join(opts.tmpdir, fn)
download_file(fn, url, tmp_path)

sha256 = compute_checksum(tmp_path, checksum_type='sha256')
print("SHA256 checksum for %s: %s" % (fn, sha256))

target_dir = os.getcwd()
copy_file(tmp_path, target_dir)
print("%s copied to %s" % (fn, target_dir))

# cleanup temp dir
remove_dir(opts.tmpdir)
```

Example output:
```shell
$ export TEST_URL='https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/eb-tutorial-1.0.1.tar.gz'
$ python3 download_and_copy.py $TEST_URL
== Temporary log file in case of crash /tmp/eb-or_xhaw8/easybuild-ewooa00c.log
SHA256 checksum for eb-tutorial-1.0.1.tar.gz: d6cec2ea298f4092cb1b880cb017220ab191561da941e9e480639cf3354b7ef9
eb-tutorial-1.0.1.tar.gz copied to /home/example
```
We are deliberately *not* specifying the `args` optional argument to the `set_up_configuration` call here,
so we can pass EasyBuild configuration options as command line arguments to this script.
Of course, only those configuration options that are taken into account by the EasyBuild
framework functions being called have any impact. For example:

```shell
# wait for max. 1h for the download to complete
python3 download_and_copy.py $TEST_URL --download-timeout 3600
```

### Running shell commands

To run shell commands, we can leverage the ``run_cmd`` functions from the ``easybuild.tools.run`` module.

Here is a simple example for running the '`make`' command via a Python script:

```python
#!/usr/bin/env python3
import sys

from easybuild.tools.filetools import remove_dir, which
from easybuild.tools.run import run_cmd
from easybuild.tools.options import set_up_configuration

opts, _ = set_up_configuration(args=[])

cmd = 'make'
cmd_path = which(cmd)
if cmd_path:
    print(">>> '%s' command found at %s" % (cmd, cmd_path))
else:
    sys.stderr.write("ERROR: '%s' command not found!\n" % cmd)
    sys.exit(1)

cmd = ' '.join(["make"] + sys.argv[1:])
out, ec = run_cmd(cmd)

print("\n>>> Output of '%s' (exit code %s):\n\n%s" % (cmd, ec, out))

remove_dir(opts.tmpdir)
```

Note that in this case it is important to use `args=[]` when calling `set_up_configuration`,
to avoid that the additional script arguments which are options for the '`make`' command
are picked up by the EasyBuild option parser.

Example usage:

```shell
$ python3 run_make.py --version
== Temporary log file in case of crash /tmp/eb-zfvbceg6/easybuild-7tynetaj.log

>> Output of 'make --version' (exit code 0):

GNU Make 3.81
```

### Interacting with the modules tool

You can interact with the environment modules tool in a Python script using the
[``easybuild.tools.modules``](https://docs.easybuild.io/en/latest/api/easybuild.tools.modules.html)
Python module that is a part of the EasyBuild framework.
The modules tool that will be used is determined by the active EasyBuild configuration.

Here is an example script that checks which modules are available and currently loaded,
loads the default module file for ``bzip2``, and inspects the resulting changes to the environment.

```python
#!/usr/bin/env python3
import os
import sys

from easybuild.tools.filetools import remove_dir
from easybuild.tools.modules import get_software_root_env_var_name, modules_tool
from easybuild.tools.options import set_up_configuration

opts, _ = set_up_configuration()

# obtain ModulesTool instance for preferred modules tool (determined by active EasyBuild configuration)
mod_tool = modules_tool()
print("Active modules tool: %s version %s" % (mod_tool.NAME, mod_tool.version))

avail_modules = mod_tool.available()
print("Found %d available modules in total" % len(avail_modules))

avail_eb_modules = mod_tool.available('EasyBuild')
print("Found %d available modules for EasyBuild: %s" % (len(avail_eb_modules), ', '.join(avail_eb_modules)))

loaded_modules = mod_tool.loaded_modules()
print("%d modules are currently loaded: %s" % (len(loaded_modules), ', '.join(loaded_modules)))

# load default module for bzip2, check changes to environment
name = 'bzip2'
env_var_name = get_software_root_env_var_name(name)
if any(m.startswith(name + '/') for m in avail_modules):

    print("Current $%s value: %s" % (env_var_name, os.getenv(env_var_name, '(no set)')))
    print("Loading (default) '%s' module..." % name)

    mod_tool.load([name])
    print("Loaded modules: %s" % ', '.join(mod_tool.loaded_modules()))

    # inspect $_LMFILES_ environment variable to determine path to loaded bzip2 module file
    for mod_file_path in os.getenv('_LMFILES_').split(':'):
        if name in mod_file_path:
            print("Path to loaded %s module: %s" % (name, mod_file_path))
            break

    # $EBROOTBZIP2 should be set now (if the bzip2 module was installed with EasyBuild)
    print("Current $%s value: %s" % (env_var_name, os.getenv(env_var_name, '(no set)')))
else:
    sys.stderr.write("No modules available for %s\n" % name)
    sys.exit(1)

remove_dir(opts.tmpdir)
```

### Parsing easyconfig files

Here is another small example Python script, which uses the EasyBuild framework functionality
to locate and parse an easyconfig file, and inspect the value of specific easyconfig parameters.

We define a small helper function named ``parse_easyconfig``, because the EasyBuild framework API
is a bit awkward to use for this simple use case.

```python
#!/usr/bin/env python3
import sys

from easybuild.framework.easyconfig.tools import det_easyconfig_paths, parse_easyconfigs
from easybuild.tools.options import set_up_configuration


def parse_easyconfig(ec_fn):
    """
    Helper function: find and parse easyconfig with specified filename,
    and return parsed easyconfig file (an EasyConfig instance).
    """
    # determine path to easyconfig file
    ec_path = det_easyconfig_paths([ec_fn])[0]

    # parse easyconfig file;
    # the 'parse_easyconfigs' function expects a list of tuples,
    # where the second item indicates whether or not the easyconfig file was automatically generated or not
    ec_dicts, _ = parse_easyconfigs([(ec_path, False)])

    # only retain first parsed easyconfig, ignore any others (which are unlikely anyway)
    return ec_path, ec_dicts[0]['ec']


# check whether required arguments are provided
if len(sys.argv) < 3:
    sys.stderr.write("ERROR: Usage: %s <name of easyconfig file> <easyconfig parameter name(s)>")
    sys.exit(1)

ec_fn = sys.argv[1]
keys = sys.argv[2:]

set_up_configuration(args=[], silent=True)

ec_path, ec = parse_easyconfig(ec_fn)

print("Inspecting %s ..." % ec_path)
for key in keys:
    print("%s: %s" % (key, ec[key]))
```

Example usage:

```shell
$ ./inspect_easyconfig.py Subread-2.0.0-GCC-8.3.0.eb name version sources sanity_check_paths
name: Subread
version: 2.0.0
sources: ['subread-2.0.0-source.tar.gz']
sanity_check_paths: {'files': ['bin/exactSNP', 'bin/featureCounts', 'bin/subindel', 'bin/subjunc', 'bin/sublong', 'bin/subread-align', 'bin/subread-buildindex'], 'dirs': ['bin/utilities']}
```

---

*[[next: Using hooks to customise EasyBuild]](3_02_hooks.md)*
