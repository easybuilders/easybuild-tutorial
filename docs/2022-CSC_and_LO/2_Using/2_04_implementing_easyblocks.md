# Implementing easyblocks

*[[back: Using external modules from the Cray PE]](2_03_external_modules.md)*

---

## The basics

An *easyblock* is a Python module that implements a software build and installation procedure.

This concept is essentially implemented as a Python script that plugs into the EasyBuild framework.

EasyBuild will leverage easyblocks as needed, depending on which software packages it needs to install. Which easyblock is required is determined by the ``easyblock`` easyconfig parameter, if it is present, or by the software name.


## Generic vs software-specific easyblocks

Easyblocks can either be *generic* or *software-specific*.

*Generic* easyblocks implement a "standard" software build and installation procedure that is used by multiple different
software packages.
A commonly used example is the
[``ConfigureMake``](https://github.com/easybuilders/easybuild-easyblocks/blob/main/easybuild/easyblocks/generic/configuremake.py)
generic easyblock, which implements the standard ``configure`` - ``make`` - ``make install`` installation procedure used
by most GNU software packages.

*Software-specific* easyblocks implement the build and installation procedure for a particular software package.
Typically this involves highly customised steps, for example specifying dedicated configuration options, creating
or adjusting specific files, executing non-standard shell commands, etc. Usually a custom implementation of the
sanity check is also included. Much of the work done in software-specific easyblocks can often also be done 
in generic easyblocks using parameters such as ``confdigopts`` etc., but a software-specific easyblock can
hide some of that complexity from the user. Other software-specific easyblocks implement very specific
installation procedures that do not fit in one of the generic ones.

Using a generic easyblock requires specifying the ``easyblock`` parameter in the easyconfig file.
If it is not specified, EasyBuild will try and find the software-specific easyblock derived from the software name.

The distinction between generic and software-specific easyblocks can be made based on the naming scheme that is used
for an easyblock (see below).


## Naming

Easyblocks need to follow a strict naming scheme, to ensure that EasyBuild can pick them up automatically as needed. 
This involves two aspects:

* the name of the Python class;
* the name and location of the Python module file.

### Python class name

The name of the Python class is determined by the *software name* for software-specific easyblocks.
It consists of a prefix '``EB_``', followed by the (encoded) software name.

Because of limitations in Python on characters allowed in names of Python classes,
only alphanumeric characters and underscores (``_``) are allowed. Any other characters are replaced following an encoding scheme:

* spaces are replaced by underscores (``_``);
* dashes ``-`` are replaced by ``_minus_`` (note the inconsistency with the naming of ``EBROOT`` and ``EBVERSION`` variables);
* underscores are replaced by ``_underscore_``;

The ``encode_class_name`` function provided in ``easybuild.tools.filetools`` returns the expected class name
for a given software name; for example:

```shell
$ python3 -c "from easybuild.tools.filetools import encode_class_name; print(encode_class_name('netCDF-Fortran'))"
EB_netCDF_minus_Fortran
```

**Python class name for *generic* easyblocks**

For *generic* easyblocks, the class name does *not* include an ``EB_`` prefix (since there is no need for an escaping
mechanism) and hence the name is fully free to choose, taking into account the restriction to alphanumeric characters
and underscores.

For code style reasons, the class name should start with a capital letter and use CamelCasing.

Examples include ``Bundle``, ``ConfigureMake``, ``CMakePythonPackage``.

### Python module name and location

The *filename* of the Python module is directly related to the name of Python class it provides.

It should:

* *not* include the ``EB_`` prefix of the class name for software-specific easyblocks;
* consists only of lower-case alphanumeric characters (``[a-z0-9]``) and underscores (``_``);
    * dashes (``-``) are replaced by underscores (``_``);
    * any other non-alphanumeric characters (incl. spaces) are simply dropped;

Examples include:

* ``gcc.py`` (for *GCC*)
* ``netcdf_fortran.py`` (for *netCDF-Fortran*)
* ``gamess_us.py`` (for *GAMESS (US)*)

The ``get_module_path`` function provided by the EasyBuild framework in the
``easybuild.framework.easyconfig.easyconfig`` module returns the (full)
module location for a particular software name or easyblock class name. For example:

```python
>>> from easybuild.framework.easyconfig.easyconfig import get_module_path
>>> get_module_path('netCDF-Fortran')
'easybuild.easyblocks.netcdf_fortran'
>>> get_module_path('EB_netCDF_minus_Fortran')
'easybuild.easyblocks.netcdf_fortran'
```

The location of the Python module is determined by whether the easyblock is generic or software-specific.
Generic easyblocks are located in the ``easybuild.easyblocks.generic`` namespace, while software-specific easyblocks
live in the ``easybuild.easyblocks`` namespace directly.

To keep things organised, the actual Python module files
for software-specific easyblocks are kept in 'letter' subdirectories,
rather than in one large '``easyblocks``' directory
(see
[https://github.com/easybuilders/easybuild-easyblocks/tree/main/easybuild/easyblocks](https://github.com/easybuilders/easybuild-easyblocks/tree/main/easybuild/easyblocks)),
but this namespace is collapsed transparently by EasyBuild (you don't need to import from letter subpackages).

To let EasyBuild pick up one or more new or customized easyblocks, you can use the [``--include-easyblocks``](https://docs.easybuild.io/en/latest/Including_additional_Python_modules.html#including-additional-easyblocks-include-easyblocks)
configuration option. As long as both the filename of the Python module and the name of the Python class
are correct, EasyBuild will use these easyblocks when needed.

On LUMI, the EasyBuild configuration modules take care of setting this parameter (using the corresponding environment
variable), pointing to custom easyblocks in the LUMI software stack itself and a repo (with a fixed name) that users
can create themselves. At this moment it does not yet include possible other easyblock repositories in other repositories.


## Structure of an easyblock

The example below shows the overal structure of an easyblock:

```python
from easybuild.framework.easyblock import EasyBlock
from easybuild.tools.run import run_cmd


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def configure_step(self):
        """Custom implementation of configure step for Example"""

        # run configure.sh to configure the build
        run_cmd("./configure.sh --install-prefix=%s" % self.installdir)
```


Each easyblock includes an implementation of a ``class`` that (directly or indirectly) derives from the abstract
``EasyBlock`` class.

Typically some useful functions provided by the EasyBuild framework are imported at the top of the Python module.

In the class definition, one or more '``*_step``' methods (and perhaps a couple of others) are redefined,
to implement the corresponding step in the build and installation procedure.

Each easyblock *must* implement the ``configure``, ``build`` and ``install`` steps, since these are not implemented
in the abstract ``EasyBlock`` class. This could be done explicitly by redefining the corresponding ``*_step`` methods,
or implicitly by deriving from existing (generic) easyblocks.

The full list of methods that can be redefined in an easyblock can be consulted in
the [API documentation](https://docs.easybuild.io/en/latest/api/easybuild.framework.easyblock.html).

## Deriving from existing easyblocks

When implementing an easyblock, it is common to derive from an existing (usually generic) easyblock,
and to leverage the functionality provided by it. This approach is typically used when only a specific part
of the build and installation procedure needs to be customised.

In the (fictitious) example below, we derive from the generic ``ConfigureMake`` easyblock to redefine the ``configure``
step. In this case, we are *extending* the ``configure`` step as implemented by ``ConfigureMake`` rather than
redefining it entirely, since we call out to the original ``configure_step`` method at the end.

```python
from easybuild.easyblocks.generic.configuremake import ConfigureMake
from easybuild.tools.filetools import copy_file


class EB_Example(ConfigureMake):
    """Custom easyblock for Example"""

    def configure_step(self):
        """Custom implementation of configure step for Example"""

        # use example make.cfg for x86-64
        copy_file('make.cfg.x86', 'make.cfg')

        # call out to original configure_step implementation of ConfigureMake easyblock
        super(EB_Example, self).configure_step()
```

## Easyconfig parameters

All of the easyconfig parameters that are defined in an easyconfig file
are available via the ``EasyConfig`` instance that can be accessed through ``self.cfg`` in an easyblock.
For instance, if the easyconfig file specifies

```python
name = 'example'
version = '2.5.3'
versionsuffix = '-Python-3.7.4'
```

then these three parameters are accessible within an easyblock via ``self.cfg['name']``, ``self.cfg['version']``
and ``self.cfg['versionsuffix']``.

A few of the most commonly used parameters can be referenced directly:

* **``self.name``** is equivalent with ``self.cfg['name']``;
* **``self.version``** is equivalent with ``self.cfg['version']``;
* **``self.toolchain``** is equivalent with ``self.cfg['toolchain']``;


### Updating parameters

You will often find that you need to *update* some easyconfig parameters in an easyblock,
for example ``configopts`` which specifies options for the configure command.

Because of implementation details (related to
how template values like ``%(version)s`` are handled), you need to be a bit careful here...

To completely redefine the value of an easyconfig parameter, you can use simple assignment. For example:

```python
self.cfg['example'] = "A new value for the example easyconfig parameter."
```

If want to *add* to the existing value however, you *must* use the ``self.cfg.update`` method. For example:

```python
self.cfg.update('some_list', 'example')
```

One could be tempted to use

```python
# anti-pattern, this does NOT work as expected!
self.cfg['some_list'].append('example')
```

instead, but this will ***not*** work because ``self.cfg['some_list']`` does not return a reference to the original value,
but to a *temporary copy* thereof.



### Custom parameters

Additional custom easyconfig parameters can be defined in an easyblock to steer its behaviour.
This is done via the ``extra_options`` *static* method. Custom parameters can be specified to be mandatory.

The example below shows how this can be implemented:

```python
from easybuild.easyblocks.generic.configuremake import ConfigureMake
from easybuild.framework.easyconfig import CUSTOM, MANDATORY


class EB_Example(ConfigureMake):
    """Custom easyblock for Example"""

    @staticmethod
    def extra_options():
        """Custom easyconfig parameters for Example"""
        extra_vars = {
            'required_example_param': [None, "Example required custom parameter", MANDATORY],
            'optional_example_param': [None, "Example optional custom parameter", CUSTOM],
        }
        return ConfigureMake.extra_options(extra_vars)
```

The first element in the list of a defined custom parameter corresponds to the default value for that parameter
(both ``None`` in the example above). The second element provides some informative help text
(which can then be displayed with ``eb -a -e <name_of_easyblock>``, eg, ``eb -a -e EB_GCC``), 
and the last element
indicates whether the parameter is mandatory (``MANDATORY``) or just an optional custom parameter (``CUSTOM``).

## Easyblock constructor

In the ``class`` constructor of the easyblock, i.e. the ``__init__`` method, one or more class variables
can be initialised. These can be used for sharing information between different ``*_step`` methods in the easyblock.

For example:

```python
from easybuild.framework.easyblock import EasyBlock


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def __init__(self, *args, **kwargs):
        """Constructor for Example easyblock, initialises class variables."""

        # call out to original constructor first, so 'self' (i.e. the class instance) is initialised
        super(EB_Example, self).__init__(*args, **kwargs)

        # initialise class variables
        self.example_value = None
        self.example_list = []
```

## File operations

File operations is a common use case for implementing easyblocks, hence the EasyBuild framework provides a
number of useful functions related to this, including:

* ``read_file(<path>)``: read file at a specified location and returns its contents;

* ``write_file(<path>, <text>)`` at a specified location with provided contents;
  to append to an existing file, use ``append=True`` as an extra argument;

* ``copy_file(<src>, <dest>)`` to copy an existing file;

* ``apply_regex_substitutions(<path>, <list of regex substitutions>)`` to patch an existing file;

All of these functions are provided by the [``easybuild.tools.filetools``](https://docs.easybuild.io/en/latest/api/easybuild.tools.filetools.html) module.

## Executing shell commands

For executing shell commands two functions are provided by the
[``easybuild.tools.run``](https://docs.easybuild.io/en/latest/api/easybuild.tools.run.html) module:

* ``run_cmd(<cmd>)`` to run a non-interactive shell command;

* ``run_cmd_qa(<cmd>, <dict with questions & answers>)`` to run an interactive shell command;

Both of these accept a number of optional arguments:

* ``simple=True`` to just return ``True`` or ``False`` to indicate a successful execution,
  rather than the default return value, i.e., a tuple that provides the command output and the exit code (in that
  order);

* ``path=<path>`` to run the command in a specific subdirectory;

The ``run_cmd_qa`` function takes two additional specific arguments:

* ``no_qa=<list>`` to specify a list of patterns to recognize non-questions;

* ``std_qa=<dict>`` to specify regular expression patterns for common questions, and the matching answer;

## Manipulating environment variables

To (re)define environment variables, the ``setvar`` function provided by the
[``easybuild.tools.environment``](https://docs.easybuild.io/en/latest/api/easybuild.tools.environment.html)
module should be used.

This makes sure that the changes being made to the specified environment variable are kept track of,
and that they are handled correctly under ``--extended-dry-run``.

## Logging and errors

It is good practice to include meaningful log messages in the ``*_step`` methods being customised in the easyblock,
to enrich the EasyBuild log with useful information for later debugging or diagnostics.

For logging, the provided ``self.log`` logger class should be used.
You can use the ``self.log.info`` method to log an informative message.
Similar methods are available for logging debug messages (``self.log.debug``), which are
only emitted when ``eb`` is run with debugging mode enabled (``--debug`` or ``-d``),
and for logging warning messages (``self.log.warning``).

If something goes wrong, you can raise an ``EasyBuildError`` instance to report the error.

For example:

```python
from easybuild.framework.easyblock import EasyBlock
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def configure_step(self):
        """Custom implementation of configure step for Example"""

        cmd = "./configure --prefix %s" % self.installdir)
        out, ec = run_cmd(cmd)

        success = 'SUCCESS'
        if success in out:
            self.log.info("Configuration command '%s' completed with success." % cmd)
        else:
            raise EasyBuildError("Pattern '%s' was not found in output of '%s'." % (success, cmd))
```

## Custom sanity check

For software-specific easyblocks, a custom sanity check is usually included to verify that the installation was
successful or not.

This is done by redefining the ``sanity_check_step`` method in the easyblock. For example:

```python
from easybuild.framework.easyblock import EasyBlock

class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def sanity_check_step(self):
        """Custom sanity check for Example."""

        custom_paths = {
            'files': ['bin/example'],
            'dirs': ['lib/examples/'],
        }
        custom_commands = ['example --version']

        # call out to parent to do the actual sanity checking, pass through custom paths and commands
        super(EB_Example, self).sanity_check_step(custom_paths=custom_paths, custom_commands=custom_commands)
```

You can both specify file paths and subdirectories to check for, which are specified relative to the installation directory,
as well as simple commands that should execute successfully after completing the installation and loading the generated module file.

It is up to you how extensive you make the sanity check, but it is recommended to make the check as complete
as possible to catch any potential build or installation problems that may occur, while ensuring that it can
run relatively quickly (in seconds, or at most a couple of minutes).

## Version-specific parts

In some cases version-specific actions or checks need to be included in an easyblock.
For this, it is recommended to use ``LooseVersion`` rather than directly comparing version numbers using string values.

For example:

```python
from distutils.version import LooseVersion
from easybuild.framework.easyblock import EasyBlock


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def sanity_check_step(self):
        """Custom sanity check for Example."""

        custom_paths = {
            'files': [],
            'dirs': [],
        }

        # in older versions, the binary used to be named 'EXAMPLE' rather than 'example'
        if LooseVersion(self.version) < LooseVersion('1.0'):
            custom_paths['files'].append('bin/EXAMPLE')
        else:
            custom_paths['files'].append('bin/example')

        super(EB_Example, self).sanity_check_step(custom_paths=custom_paths)
```

## Compatibility with ``--extended-dry-run`` and ``--module-only``

Some special care must be taken to ensure that an easyblock is fully compatible with ``--extended-dry-run`` / ``-x``
(see [Inspecting install procedures](../../1_Intro/1_08_basic_usage/#inspecting-install-procedures)) and ``--module-only``.

For compatibility with ``--extended-dry-run``, you need to take into account that specified operations
like manipulating files or running shell commands will not actually be executed. You can check
whether an easyblock is being run in dry run mode via ``self.dry_run``.

For example:

```python
from easybuild.framework.easyblock import EasyBlock
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def configure_step(self):
        """Custom implementation of configure step for Example"""

        cmd = "./configure --prefix %s" % self.installdir)
        out, ec = run_cmd(cmd)

        success = 'SUCCESS'
        if success in out:
            self.log.info("Configuration command '%s' completed with success." % cmd)

        # take into account that in dry run mode we won't get any output at all
        elif self.dry_run:
            self.log.info("Ignoring missing '%s' pattern since we're running in dry run mode." % success)

        else:
            raise EasyBuildError("Pattern '%s' was not found in output of '%s'." % (success, cmd))
```

For ``--module-only``, you should make sure that both the ``make_module_step``, including the ``make_module_*`` submethods,
and the ``sanity_check_step`` methods do not make any assumptions about the presence of certain environment variables, or that class variables have been defined already.

This is required because under ``--module-only`` the large majority of the ``*_step`` functions are
simply *skipped* entirely. So, if the ``configure_step`` method is responsible for defining class variables that are
picked up in ``sanity_check_step``, the latter may run into unexpected initial values like ``None``.
A possible workaround is to define a separate custom method to define the class variables, and to call out to this
method from ``configure_step`` and ``sanity_check_step`` (for the latter, conditionally, i.e., only if the class
variables still have the initial values).

For example:

```python
from easybuild.framework.easyblock import EasyBlock


class EB_Example(EasyBlock):
    """Custom easyblock for Example"""

    def __init__(self, *args, **kwargs):
        """Easyblock constructor."""
        super(EB_Example, self).__init__(*args, **kwargs)

        self.command = None

    def set_command(self):
        """Initialize 'command' class variable."""
        # $CC environment variable set by 'prepare' step determines exact command
        self.command = self.name + '-' + os.getenv('CC')

    def configure_step(self):
        """Custom configure step for Example."""

        self.set_command()
        self.cfg.update('configopts', "COMMAND=%s" % self.command)

        super(EB_Example, self).configure_step()

    def sanity_check_step(self):
        """Custom implementation of configure step for Example"""

        if self.command is None:
            self.set_command()

        super(EB_Example, self).sanity_check_step(custom_commands=[self.command])
```


## Easyblocks in the Cray ecosystem

The generic easyblocks are usually rather independent of compilers etc. and tend to work well with all toolchains.
However, software-specific easyblocks may contain code that is specific for certain toolchains and are often only
tested with the common toolchains (foss and intel and their subtoolchains). Many of those easyblocks will fail
on Cray systems (or any system that uses other toolchains) as they don't recognise the compiler and rather than
implementing some generic behaviour that may or may not work, produce an error message instead that the compiler
toolchain is not supported.

Several packages on LUMI therefore use generic easyblocks rather than the software-specific easyblocks that may 
exist for those applications. Adapting those software-specific easyblocks for LUMI poses an interesting maintenance
problem. Either one could decide to not contribute back to the community, but this implies then that all modifications
made to the corresponding easyblocks in the EasyBuild distribution should be monitored and implemented in the custom
easyblocks for Cray also. On the other hand, contributing back to the community also poses two problems. First it
would also require to implement the Cray toolchains as used on LUMI in the core of EasyBuild (which already contains
a different set of toolchains targeted more at how the Cray PE works with the regular environment modules), and that
only makes sense if these toolchains are first extended to not only cover the programming environments supported on 
LUMI but also the Intel and NVIDIA programming environments. Second, the EasyBuild community has no easy way of testing
any modification made to such an easyblock on a Cray PE system. Hence every update made in the community may break
the Cray PE support again.


## Exercise

### Exercise I.1

Try implementing a new custom easyblock for ``eb-tutorial``, which derives directly
from the base ``EasyBlock`` class.

Your easyblock should:

* define a custom mandatory easyconfig parameter named ``message``;
* run `cmake` to configure the installation, which includes at least:
    * specifying the correct installation prefix (using the `-DCMAKE_INSTALL_PREFIX=...` option);
    * passing down the value of ``message`` easyconfig parameter via `-DEBTUTORIAL_MSG=...`
* run `make` to build `eb-tutorial`;
* run `make install` to install the generated binary;
* perform a custom sanity check to ensure the installation is correct;
* pick up on commonly used easyconfig parameters like `configopts` and `preinstallopts` where appropriate;

??? success "(click to show solution)"

    Here's a complete custom easyblock for ``eb-tutorial`` that derives from the base ``EasyBlock`` class,
    which should be included in a file named ``eb_tutorial.py``.

    We need to implement the ``configure_step``, ``build_step``, and ``install_step`` methods in
    order to have a fully functional easyblock.

    The configure, build, and install steps take into account the corresponding easyconfig
    parameters that allow customizing these commands from an easyconfig file.

    ```python
    from easybuild.framework.easyblock import EasyBlock
    from easybuild.framework.easyconfig import MANDATORY
    from easybuild.tools.run import run_cmd


    class EB_eb_minus_tutorial(EasyBlock):
        """Custom easyblock for eb-tutorial."""

        @staticmethod
        def extra_options():
            extra = EasyBlock.extra_options()
            extra.update({
                'message': [None, "Message that eb-tutorial command should print", MANDATORY],
            })
            return extra

        def configure_step(self):
            """Custom configure step for eb-tutorial: define EBTUTORIAL_MSG configuration option."""

            cmd = ' '.join([
                self.cfg['preconfigopts'],
                'cmake',
                '-DCMAKE_INSTALL_PREFIX=\'%s\'' % self.installdir,
                '-DEBTUTORIAL_MSG="%s"' % self.cfg['message'],
                self.cfg['configopts'],
            ])
            run_cmd(cmd)

        def build_step(self):
            """Build step for eb-tutorial"""

            cmd = ' '.join([
                self.cfg['prebuildopts'],
                'make',
                self.cfg['buildopts'],
            ])
            run_cmd(cmd)

        def install_step(self):
            """Install step for eb-tutorial"""

            cmd = ' '.join([
                self.cfg['preinstallopts'],
                'make install',
                self.cfg['installopts'],
            ])
            run_cmd(cmd)

        def sanity_check_step(self):
            custom_paths = {
                'files': ['bin/eb-tutorial'],
                'dirs': [],
            }
            custom_commands = ['eb-tutorial']
            return super(EB_eb_minus_tutorial, self).sanity_check_step(custom_paths=custom_paths,
                                                                       custom_commands=custom_commands)
    ```

    We also need to adapt our easyconfig file for ``eb-tutorial``:

    -   The ``easyblock`` line is no longer needed as we will rely on the automatic selection of the
        software-specific easyblock.
    -   We don't need to define the message through ``configopts`` but via the easyblock-specific 
        configuration parameter ``message``. In fact, we were so careful when implementing the ``configure_step``
        that even variable expansion will still work so we can still include ``$USER`` in the message.
    -   The sanity check is also no longer needed as it is done by the software-specific easyblock.

    So the easyconfig file simplifies to:

    ```python
    name = 'eb-tutorial'
    version = "1.1.0"

    homepage = 'https://easybuilders.github.io/easybuild-tutorial'

    whatis = [ 'Description: EasyBuild tutorial example']

    description = """
    This is a short C++ example program that can be build using CMake.
    """

    toolchain = {'name': 'cpeCray', 'version': '21.12'}

    builddependencies = [
      ('buildtools', '%(toolchain_version)s', '', True)
    ]

    source_urls = ['https://github.com/easybuilders/easybuild-tutorial/raw/main/docs/files/']
    sources = [SOURCE_TAR_GZ]
    checksums = ['def18b69b11a3ec34ef2a81752603b2118cf1a57e350aee41de9ea13c2e6a7ef']

    message = 'Hello from the EasyBuild tutorial! I was installed by $USER.'

    moduleclass = 'tools'

    ```

    Running this example on LUMI is a little tricky as using ``--include-easyblocks`` to point EasyBuild to
    our new easyblock interfers with settings already made by the EasyBuild configuration modules (``EasyBuild-user``)
    and causes error messages about the toolchains. So either the easyblock needs to be copied to the user location
    that can be found by looking at the output of ``eb --show-config`` or we simply need to extend the list of
    easyblocks that EasyBuild searches with the easyblocks in the current directory:

    ``` shell
    EASYBUILD_INCLUDE_EASYBLOCKS="$EASYBUILD_INCLUDE_EASYBLOCKS,./*.py"
    ```




### Exercise I.2

Try implementing another new custom easyblock for ``eb-tutorial``,
which derives from the generic ``CMakeMake`` easyblock.

Your easyblock should only:

* define a custom mandatory easyconfig parameter named ``message``;
* pass down the value of ``message`` easyconfig parameter via `-DEBTUTORIAL_MSG=...`
* perform a custom sanity check to ensure the installation is correct;

??? success "(click to show solution)"

    When deriving from the ``CMakeMake`` generic easyblock, there is a lot less to worry about.

    We only need to customize the ``configure_step`` method to ensure that the ``-DEBTUTORIAL_MSG`` configuration
    option is specified; the ``CMakeMake`` easyblock already takes care of specifying the location of
    the installation directory (and a bunch of other configuration options, like compiler commands and flags, etc.).

    Implementing the ``build_step`` and ``install_step`` methods is no longer needed,
    the standard procedure that is run by the ``CMakeMake`` generic easyblock is fine,
    and even goes beyond what we did in the previous exercise (like building in parallel with ``make -j``).

    ```python
    from easybuild.easyblocks.generic.cmakemake import CMakeMake
    from easybuild.framework.easyconfig import MANDATORY
    from easybuild.tools.run import run_cmd

    class EB_eb_minus_tutorial(CMakeMake):
        """Custom easyblock for eb-tutorial."""

        @staticmethod
        def extra_options():
            extra = CMakeMake.extra_options()
            extra.update({
                'message': [None, "Message that eb-tutorial command should print", MANDATORY],
            })
            return extra

        def configure_step(self):
            """Custom configure step for eb-tutorial: define EBTUTORIAL_MSG configuration option."""
            self.cfg.update('configopts', '-DEBTUTORIAL_MSG="%s"'% self.cfg['message'])

            super(EB_eb_minus_tutorial, self).configure_step()

        def sanity_check_step(self):
            custom_paths = {
                'files': ['bin/eb-tutorial'],
                'dirs': [],
            }
            custom_commands = ['eb-tutorial']
            return super(EB_eb_minus_tutorial, self).sanity_check_step(custom_paths=custom_paths,
                                                                       custom_commands=custom_commands)
    ```

    This is a much simpler easyblock as we already use all the logic that has been written for us to build
    with CMake.

*[[next: EasyBuild as a library]](../3_Advanced/3_01_easybuild_library.md)*
