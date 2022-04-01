# Using external modules from the Cray PE

*[[back: Creating easyconfig files]](2_02_creating_easyconfig_files.md)*

---

## What are external modules?

EasyBuild supports the use of modules that were not installed via EasyBuild. 
We refer to such modules as [external modules](https://docs.easybuild.io/en/latest/Using_external_modules.html).
These modules do not define the `EBROOT*` and `EBVERSION*` environment variables that EasyBuild would define
and uses internally in several easyblocks and some easyconfig files.

This feature is used extensively on Cray systems to interface with the Cray PE (which comes with its own
modules and cannot be installed via EasyBuild):
[external modules can be used as dependencies](https://docs.easybuild.io/en/latest/Using_external_modules.html#using-external-modules-as-dependencies), 
by including the module name in the dependencies list, 
along with the `EXTERNAL_MODULE` constant marker.

For example, to specify the module `cray-fftw` as a dependency, you should write the following in your easyconfig file:
``` python
dependencies = [('cray-fftw', EXTERNAL_MODULE)]
```

For such dependencies, EasyBuild will:

* load the module before initiating the software build and install procedure

* include a `module load` statement in the generated module file (for runtime dependencies)

!!! Note
    The default version of the external module will be loaded unless a specific version is given as dependency,
    and here that version needs to be given as part of the name of the module and not as the second element in the
    tuple.

    ```python
    dependencies = [('cray-fftw/3.3.8.12', EXTERNAL_MODULE)]
    ```

If the specified module is not available, EasyBuild will exit with an error message stating that the dependency 
can not be resolved because the module could not be found, without searching for a matching easyconfig file
from which it could generate the module.


---

## EasyBuild Metadata for external modules

[Metadata](https://docs.easybuild.io/en/latest/Using_external_modules.html#metadata-for-external-modules)
 can be supplied to EasyBuild for external modules: using the `--external-modules-metadata` 
configuration option, the location of one or more metadata files can be specified.

The files are expected to be in INI format, with a section per module name 
and key-value assignments specific to that module.

The external modules metadata file can be also defined with the corresponding environment variable:
```
echo $EASYBUILD_EXTERNAL_MODULES_METADATA 
/apps/common/UES/jenkins/production/easybuild/cpe_external_modules_metadata-21.04.cfg
```

The following keys are 
[supported by EasyBuild](https://docs.easybuild.io/en/latest/Using_external_modules.html#supported-metadata-values):

* name: software name(s) provided by the module
* version: software version(s) provided by the module
* prefix: installation prefix of the software provided by the module

For instance, the external module version loaded by the dependency `cray-fftw` can be specified as follows:
```ini
[cray-fftw]
name = FFTW
prefix = FFTW_DIR/..
version = 3.3.8.10
```

The environment variable `$EBROOTFFTW` will also be defined according to the `prefix` specified in the metadata file.

---

*[[next: Implementing easyblocks]](2_04_implementing_easyblocks.md)*
