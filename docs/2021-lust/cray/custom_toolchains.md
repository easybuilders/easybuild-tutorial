# Custom Cray toolchains

EasyBuild Cray and CPE toolchains have been created to address the Cray PE on different Cray systems. 

Cray toolchains were designed for the Cray PE on the Cray XC system, 
while the CPE toolchains targeted specifically the Cray PE on the Cray EX system.

As of Cray PE 21.04 though, the difference between the Cray PE on the XC and
the EX systems is not relevant any longer, since they rely both on PrgEnv meta-modules.

Nonetheless, the versions of the CPE components that come with a Cray PE release might change 
depending on the target system, therefore a different external metadata file is required:

* see [https://github.com/eth-cscs/production/tree/master/easybuild](https://github.com/eth-cscs/production/tree/master/easybuild) to inspect the difference between two metadata file referring to the same version 

* E.g.: `cpe_external_modules_metadata-21.05.cfg` vs. `cray_external_modules_metadata-20.05.cfg`

Furthermore, different easyconfig files might be needed to build the same software on the 
two systems even with the same Cray PE, therefore the maintainers would need to provide 
anyway two versions of the easyconfig file.   

--- 

## Cray Toolchains

EasyBuild supports Cray systems as of version 2.7.0, enabling building and installing software using 
the Programming Environment modulefiles provided by Cray. 

The EasyBuild Cray toolchains currently supported in the [GitHub repository](https://github.com/easybuilders/easybuild-framework) 
are the following ones:

* `CrayCCE`
* `CrayGNU`
* `CrayIntel`
* `CrayPGI`

Each Cray toolchain comes with a version matching the corresponding Cray Development Toolkit (CDT) modulefile on the 
Cray XC system. 

Therefore, the toolchain will load the corresponding Cray Programming Environment, together with the compiler, 
the Cray MPICH library and the Cray mathematical library with versions matching the definition of the CDT. 

Please note that the toolchains follow the naming convention of the Cray Programming Environment, 
that is released on a monthly basis: as a consequence, the version of the toolchain modules has 
the format `YY.MM` (two digits for the year, two digits for the month). 

---

## CPE Toolchains

The CPE toolchains were created initially to match the modules of the Cray EX system up to Cray PE 21.03:

* `cpe-cray`
* `cpe-aocc`
* `cpe-gnu`
* `cpe-intel`

As of CPE 21.04 though, the Cray PE of the Cray EX system features `PrgEnv` meta-modules too, 
therefore the difference with respect to the standard Cray toolchain has disappeared.

The CPE toolchains are defined by the custom easyblock `cpetoolchain.py`:
```
KNOWN_PRGENVS = ['PrgEnv-aocc', 'PrgEnv-cray', 'PrgEnv-gnu', 'PrgEnv-intel']
```

The [file](https://github.com/eth-cscs/production/blob/master/easybuild/easyblocks/cpetoolchain.py) is available in the [CSCS production repository on GitHub](https://github.com/eth-cscs/production), that is also mirrored under the [EasyBuilders GitHub project](https://github.com/easybuilders) at [https://github.com/easybuilders/CSCS](https://github.com/easybuilders/CSCS). 

---

## CPE Compilers

The CPE toolchains rely on specific files of the local EasyBuild framework:
```
cpeamd.py
cpecray.py
cpegnu.py
cpeintel.py
```

The first one will look for the custom compiler `aocc.py`, while the other ones are compatible 
with the compilers defined by the Cray toolchains initially defined on the XC system.

The custom toolchains above will look for the file `cpe.py` supporting the Cray PE compiler drivers. 

Please note that as well as the custom easyblock `cpetoolchain.py`, the custom files are available in the [toolchains](https://github.com/eth-cscs/production/tree/master/easybuild/toolchains) and the [compiler](https://github.com/eth-cscs/production/tree/master/easybuild/toolchains/compiler) folders of the [CSCS production repository on GitHub](https://github.com/eth-cscs/production).

---

## Target Architecture

The module `craype-<target>` matching the target architecture must be specified using the EasyBuild flag `--optarch`.

E.g.: `--optarch=x86-rome results in module `craype-x86-rome` being loaded in the build environment used by EasyBuild.

You can also export this option as a shell variable. Example for AMD EPYC 7742 ("Rome"):
```
export $EASYBUILD_OPTARCH=x86-rome
```

The definition of the correct module to load with the `--optarch` is also given by the environment variable `CRAY_CPU_TARGET`:
this variable is defined as well by the corresponding module `craype-<target>`, already available at the login. 

!!! Note
    The custom EasyBuild modulefile used on CSCS systems will look for `CRAY_CPU_TARGET` to define `--optarch`, 
    therefore users are strongly discouraged from purging the modules already available at login on the system

--- 

## Easyconfig for custom toolchains

The easyconfig files of the current default custom toolchains were using a footer to address two issues that have been fixed in the latest EasyBuild release 4.4.0.

Therefore, when using the latest EasyBuild release one could write a much shorter [easyconfig file](https://github.com/eth-cscs/production/blob/master/easybuild/easyconfigs/c/cpeGNU/cpeGNU-21.04.eb) for the custom toolchains. 

For instance, the cpeGNU custom toolchain easyconfig file would like the following:
```
# Compiler toolchain for Cray EX Programming Environment GNU compiler (cpe-gnu)
easyblock = 'cpeToolchain'

name = 'cpeGNU'
version = "21.04"

homepage = 'https://pubs.cray.com'
description = """Toolchain using Cray compiler wrapper with gcc module (CPE release: %s).\n""" % version

toolchain = SYSTEM

dependencies = [
   ('cpe/%(version)s', EXTERNAL_MODULE),
   ('PrgEnv-gnu', EXTERNAL_MODULE)
]
```

The meta-module `cpe` will ensure that the additional modules loaded by a user will be compatible with the default CPE selected.

The advantage of the approach is to avoid pinning directly the versions of CPE components in the custom toolchain definitions. 

Of course the maintainers could also decide to pin directl the version of each CPE component in the easyconfig, 
however this approach is less easy to fit in an automated pipeline for updating recipes when new CPEs are installed. 

*[[next: EasyBuild at CSCS]](easybuild_at_cscs.md)*
