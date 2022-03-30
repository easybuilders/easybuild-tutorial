# Using hooks to customise EasyBuild

*[[back: Using EasyBuild as a library]](3_01_easybuild_library.md)*

---

Sometimes you may have the need to customise the behaviour of EasyBuild,
while you want to avoid copying easyconfig files in order to make small changes
(like adding an additional configuration option), having to maintain a set
of modified easyblocks, or using a patched version of the EasyBuild framework.

EasyBuild provides support for implementing so-called *hooks*,
which are small functions that are triggered automatically at specific times.

Through these hook functions you can take additional actions, or even tweak
internal data structures, to change the software installation procedure that EasyBuild
would normally execute.

This is a very powerful feature, but it is important to aware of some details in order
to make good use of it.

Support for hooks is also covered in detail in the EasyBuild documentation, see
[here](https://docs.easybuild.io/en/latest/Hooks.html).


## Implementing and using hooks

Using hooks is done by implementing functions with specific names in a Python module,
and configuring EasyBuild to use them by specifying the path to the file that contains them
via the ``hooks`` configuration option.

For example, if the file named ``my_eb_hooks.py`` in your home directory contains the implementation
of your hooks, you can configure EasyBuild to use them by defining the ``$EASYBUILD_HOOKS`` environment
variable:

```shell
export EASYBUILD_HOOKS=$HOME/my_eb_hooks.py
```

## Available hooks

EasyBuild supports various hooks, the full list can be consulted via ``eb --avail-hooks``.

There are 3 different types of hooks:

- start/end hooks
- parse hook
- pre/post-step hooks

These are discussed in more details in the sections below.

### Start/end hooks

The first type of hooks are the ``start`` and ``end`` hooks, which are respectively triggered
at the very start of the EasyBuild session (right after setting up the EasyBuild configuration),
and at the very end of the session (right before stopping the logger and doing final cleanup).

These hooks are only called *once* for every EasyBuild session, no matter how many installations
are performed during that session.

The ``end`` hook is *not* triggered if an error occurred during one of the installations,
only on successful completion of the EasyBuild session.

These hooks can be implementing by defining a function named ``start_hook`` and ``end_hook``
in the Python module file that is provided via the ``hooks`` configuration option.
No arguments are provided when calling these hooks.

### Parse hook

The ``parse`` hook is triggered right after an easyconfig file is being parsed,
*before* EasyBuild sets up its internal data structures based on the parsed easyconfig.

If you want to dynamically change one or more easyconfig parameters without changing the corresponding
easyconfig files, using this hook may be appropriate.

Note that parsing an easyconfig file can happen for a variety of reasons,
not only when the easyconfig file will actually be installed. EasyBuild will also
parse easyconfig files to check whether they resolve required dependencies,
to check whether the corresponding module file is already installed, etc.

This hook can be implemented via a function named ``parse_hook``, and exactly one
argument is provided when it is called: the [``EasyConfig``](https://docs.easybuild.io/en/latest/api/easybuild.framework.easyconfig.easyconfig.html#easybuild.framework.easyconfig.easyconfig.EasyConfig)
instance that represents the parsed easyconfig file.

### Pre/post-step hooks

The third type of hooks are *pre/post-step* hooks, which are triggered right before or
after a particular installation step is executed.

EasyBuild performs each software installation by stepping through over a dozen different methods,
and for each of these steps there a pre- and post-hook is triggered, which results in over 30
additional hooks.

To use any of these hooks, you need to implement a function that follow a strict naming scheme:
``<pre|post>_<step-name>_hook``. For example, the hook that is triggered right before the ``configure``
step is run is a function named ``pre_configure_hook``.

Every time these hooks are called, a single argument is provided: an [``EasyBlock``](https://docs.easybuild.io/en/latest/api/easybuild.framework.easyblock.html#easybuild.framework.easyblock.EasyBlock)
instance that represents the easyblock that is being used to perform the installation.
The parsed easyconfig file can be accessed via the ``cfg`` class variable of the ``EasyBlock`` instance.

These hooks are useful for influencing the installation procedure at a particular stage.

## Caveats

There are a couple of important caveats to take into account when implementing hooks.

### Breaking EasyBuild with hooks

Since hooks allow you to inject custom code into EasyBuild at runtime,
it is also easy to break EasyBuild by using hooks...

Make sure to carefully test your hook implementations, and constrain the actions
you take a much as possible, for example by adding conditions to control for which
software names you will actually modify the installation procedure, etc.

Any errors that are triggered or raised while a hook function is running
will interrupt the EasyBuild session.

So don't forget: with great power comes great responsibility!

### Template values

Depending on the type of hook, you may observe "raw" values of easyconfig parameters where
template values have not been resolved yet, or values in which template values have been resolved already.

In the ``parse`` hook, you will always see unresolved template values.

In the pre/post-step hooks you will see resolved template values,
unless you explicitly disable templating.

To obtain easyconfig parameter values with unresolved template values in step hooks,
you can use the ``disable_templating`` [context manager](https://docs.python.org/3/reference/compound_stmts.html#with).
For example:

```python
from easybuild.framework.easyconfig.easyconfig import disable_templating
from easybuild.tools.build_log import print_warning

def pre_source_hook(eb):
    """Print warning when software version was found in 'raw' name of source file."""
    with disable_templating(eb.cfg):
        for src in eb.cfg['sources']:
            if eb.version in src:
                msg = "Software version '%s' found in name of source file (%s), " % (eb.version, src)
                msg += "please use %(version)s template value instead!"
                print_warning(msg)
```


### Manipulating easyconfig parameters

If you want update a particular easyconfig parameter without overwriting the existing value,
a bit of care has to be taken: you should use the ``update`` method of the ``EasyConfig`` instance
for this, unless you disable template resolution. This is particularly important when
updating easyconfig parameters that have *mutable* value (like a ``list`` or ``dict``).

Here's a correct example of a pre-install hook:

```python
def pre_install_hook(eb):
    if eb.name == 'pigz':
        # always copy the README directory too when installing pigz
        eb.cfg.update('files_to_copy', 'README')
```

This seemingly equivalent implementation will ***not*** work (the value of the `files_to_copy`
easyconfig parameter will *not* be updated):

```python
def pre_install_hook(eb):
    if eb.name == 'pigz':
        # incorrect way of adding 'README' to 'files_to_copy' (DON'T USE THIS!)
        eb.cfg['files_to_copy'].append('README')
```

To use this coding style successfully, you have to disable the templating mechanism
when updating the easyconfig parameter:

```python
def pre_install_hook(eb):
    if eb.name == 'pigz':
        # this works, but it is better to use the 'update' method instead...
        with disable_templating(eb.cfg):
            eb.cfg['files_to_copy'].append('README')
```

---

*[[next: Submitting installations as Slurm jobs]](3_03_slurm_jobs.md)*
