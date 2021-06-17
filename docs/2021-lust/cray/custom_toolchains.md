# Custom Cray toolchains

EasyBuild custom toolchains have been created to address the Cray Programming Environment. 

Together with the classical Cray toolchains, we have recently created CPE toolchains that 
targeted specifically the Cray Programming Environment on the Cray EX system (formerly Shasta).

As of CPE 21.04 though, the difference between the Cray Programming Environment on the XC and
the EX systems is not relevant any longer, since they rely both on the PrgEnv meta-modules.

Nonetheless, the versions of the CPE components that come with a CPE release might change 
depending on the target system, therefore a different external metadata file is required:
see [https://github.com/eth-cscs/production/tree/master/easybuild](https://github.com/eth-cscs/production/tree/master/easybuild) to inspect the difference between two metadata file referring to the same version. 

E.g.: `cpe_external_modules_metadata-21.05.cfg` vs. `cray_external_modules_metadata-20.05.cfg`

Furthermore, different easyconfig files might be needed to build the same software on the 
two systems even with the same Cray PE, therefore the maintainers would need to provide 
two versions anyway.   

-- 

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

The CPE toolchains have been created initially to match the modules of the Cray EX system up to CPE 21.03:

* `cpe-cray`
* `cpe-aocc`
* `cpe-gnu`
* `cpe-intel`

As of CPE 21.04 though, the CPE of the Cray EX system features as well `PrgEnv` meta-modules.
Therefore the difference with respect to the standard Cray toolchain has disappeared.

The CPE toolchains are defined by the custom easyblock `cpetoolchain.py`:
```
KNOWN_PRGENVS = ['PrgEnv-aocc', 'PrgEnv-cray', 'PrgEnv-gnu', 'PrgEnv-intel']
```

The [file](https://github.com/eth-cscs/production/blob/master/easybuild/easyblocks/cpetoolchain.py) is available in the [CSCS production repository on GitHub](https://github.com/eth-cscs/production), that is also mirrored under the [EasyBuilders GitHub project](https://github.com/easybuilders) at [https://github.com/easybuilders/CSCS](https://github.com/easybuilders/CSCS). 

---

## CPE Compilers

The custom CPE toolchains rely on specific files of the local EasyBuild framework:
```
cpeamd.py
cpecray.py
cpegnu.py
cpeintel.py
```

The first one will look for the custom compiler `aocc.py`, while the other ones are compatible 
with the compilers defined by the Cray toolchains initially defined on the XC system.

The custom toolchains above will look for the custom `cpe.py` supporting the Cray Programming Environment 
(craype) compiler drivers. 

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

For instale the cpeGNU custom toolchain easyconfig file would like the following:
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

The meta-module `cpe` will ensure that the additional modules loaded by a user will be compatible with the default Cray PE selected.

The advantage of the approach is to avoid pinning directly the versions of CPE components in the custom toolchain definitions. 

Of course the maintainers could also decide to pin directl the version of each CPE component in the easyconfig, 
however this approach is less easy to fit in an automated pipeline for updating recipes when new Cray PEs are installed. 

---

## Supported Applications

```
 Buildah-1.19.0.eb                    --set-default-module
 CMake-3.20.1.eb                      --set-default-module
 ddt-21.0-linux-x86_64.eb             --set-default-module
 hub-2.14.2.eb                        --set-default-module
 hwloc-2.4.1.eb                       --set-default-module
 jupyter-utils-0.1.eb                 --set-default-module
 reframe-3.5.3.eb                     --set-default-module
 xalt-2.8.10.eb                       --set-default-module
 GSL-2.6-cpeAMD-21.03.eb
 GSL-2.6-cpeCray-21.03.eb
 ParaView-5.9.0-cpeCray-21.03-OSMesa-python3.eb
 Boost-1.75.0-cpeGNU-21.03.eb
 Boost-1.75.0-cpeGNU-21.03-python3.eb --set-default-module
 CP2K-8.1-cpeGNU-21.03.eb
 GREASY-19.03-cscs-cpeGNU-21.03.eb
 GROMACS-2020.5-cpeGNU-21.03.eb
 GSL-2.6-cpeGNU-21.03.eb
 jupyterlab-2.2.8-cpeGNU-21.03.eb
 LAMMPS-29Oct20-cpeGNU-21.03.eb
 matplotlib-3.3.4-cpeGNU-21.03.eb
 NCO-4.9.8-cpeGNU-21.03.eb
 QuantumESPRESSO-6.7.0-cpeGNU-21.03.eb
 Vc-1.4.1-cpeGNU-21.03.eb           
 Amber-20-15-9-cpeIntel-21.03.eb
 GSL-2.6-cpeIntel-21.03.eb
 NAMD-2.14-cpeIntel-21.03.eb
 VASP-6.2.0-cpeIntel-21.03.eb
```

---

## Example build

```
eb --ignore-locks -r --try-toolchain-version=21.05  Amber-20-15-9-cpeIntel-21.04.eb
== Temporary log file in case of crash /run/user/23395/easybuild/tmp/eb-ss0j8hgy/easybuild-ywc85qhu.log
== found valid index for /apps/common/UES/easybuild/software/EasyBuild/4.3.4/easybuild/easyconfigs, so using it...
== resolving dependencies ...
== processing EasyBuild easyconfig /run/user/23395/easybuild/tmp/eb-ss0j8hgy/tweaked\_easyconfigs/Amber-20-15-9-cpeIntel-21.05.eb
== building and installing Toolchain/cpeIntel/21.05/Amber/20-15-9...
== fetching files...
== creating build dir, resetting environment...
== unpacking...
== patching...
== preparing...
== configuring...
== building...
== testing...
== installing...
== taking care of extensions...
== restore after iterating...
== postprocessing...
== sanity checking...
== cleaning up...
== creating module...
== permissions...
== packaging...
== COMPLETED: Installation ended successfully (took 2 hours 0 min 8 sec)
== Results of the build can be found in the log file(s) /apps/pilatus/UES/jenkins/1.4.0/software/Amber/20-15-9-cpeIntel-21.05/easybuild/easybuild-Amber-20-15-9-20210521.203937.log
== Build succeeded for 1 out of 1
== Temporary log file(s) /run/user/23395/easybuild/tmp/eb-ss0j8hgy/easybuild-ywc85qhu.log\* have been removed.
== Temporary directory /run/user/23395/easybuild/tmp/eb-ss0j8hgy has been removed.
```

*[[next: EasyBuild at CSCS]](easybuild_at_cscs.md)*
