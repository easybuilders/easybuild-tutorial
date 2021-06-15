# Custom Cray toolchains

EasyBuild custom toolchains have been created to address the Cray Programming Environment. 

Together with the classical Cray toolchains, we have recently created CPE toolchains that 
targeted specifically the Cray Programming Environment on the Cray EX system (formerly Shasta).

As of CPE 21.04 though, the difference between the Cray Programming Environment on the XC and
the EX systems is not relevant any longer, since they rely both on the PrgEnv meta-modules.

Nonetheless, the versions of the CPE components that come with a CPE release might change 
depending on the target system, therefore a different external metadata file is required.

Firthermore, different easyconfig files might be needed to build the same software on the 
two systems.    

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

The file is available in the [CSCS production repository on GitHub](https://github.com/eth-cscs/production/blob/master/easybuild/easyblocks/cpetoolchain.py). 

---

## CPE Compilers

The custom CPE toolchains rely on specific files of the local EasyBuild framework:
```
cpeamd.py
cpecray.py
cpegnu.py
cpeintel.py
```

The first one will look for the custom `aocc.py`, while the other ones are compatible with the standard Cray toolchains.

---

## Target Architecture

The module `craype-<target>` matching the target architecture must be specified using the EasyBuild flag `--optarch`.

E.g.: `--optarch= results in module `craype-x86-rome` being loaded in the build environment used by EasyBuild.

You can also export this option as a shell variable. Example for AMD EPYC 7742 ("Rome"):
```
export $EASYBUILD_OPTARCH=x86-rome
```

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
