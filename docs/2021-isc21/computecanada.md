# EasyBuild at Compute Canada

(*authors: Maxime Boissonneault & Bart Oldeman, Compute Canada)*

## General info

<img src="../../img/computecanada.png" style="float:right" width="280px"/>

Compute Canada ([https://www.computecanada.ca](https://www.computecanada.ca/)) is a national organization in Canada. Its role is to coordinate the work of regions and institutions to make advanced computing research infrastructures (clusters, cloud, data repositories) available to Canadian academic researchers. It is similar to [XSEDE](https://www.xsede.org/) in the US.

### Staff & user base

Compute Canada has around 200 full time equivalent staff located across almost 40 different institutions, in all
provinces of Canada. Its user base is composed of about 15,000 users in all disciplines, with a growth of about 20% per year.

### Resources

Compute Canada and its partners manage 4 main clusters, and 1 main OpenStack cloud.

[Cedar](https://docs.computecanada.ca/wiki/Cedar) is a general purpose cluster that uses Intel OmniPath, has two generations of GPUs (P100 and V100), and three generations of CPUs (Broadwell, Skylake and Cascade Lake), for a total of nearly 100,000 cores and 1,400 GPUs.

[Graham](https://docs.computecanada.ca/wiki/Graham) is an InfiniBand cluster with similar characteristics as Cedar, but half its size.

[Béluga](https://docs.computecanada.ca/wiki/B%C3%A9luga/en) is our third general purpose cluster, also using InfiniBand, with V100 GPUs and Skylake CPUs.

[Niagara](https://docs.computecanada.ca/wiki/Niagara) is our large parallel cluster, with a Dragonfly InfiniBand network technology, and all identical nodes with nearly 80,000 cores.

Finally, [Arbutus](https://docs.computecanada.ca/wiki/Cloud_resources) is our primary OpenStack cloud infrastructure with about 15,000 cores.


## Compute Canada software stack

Software installation is amongst the activities that are centralized by Compute Canada. We provide **a single user space environment that is available across all of the clusters** (all 4 primary clusters, with many legacy clusters also adopting the same environment). This means that users can move across clusters seamlessly, since the same modules are available everywhere.

For this to happen, especially given the variety of hardware we support, a couple of components are required. These were described in details in the paper presented at PEARC'19, which can be found [here](https://ssl.linklings.net/conferences/pearc/pearc19_program/views/includes/files/pap139s3-file1.pdf).

This work was also presented at the *EasyBuild User Meeting* in January 2020. The [recording](https://www.youtube.com/watch?v=_0j5Shuf2uE) and [slides](https://users.ugent.be/~kehoste/eum20/eum20_03_maxime_computecanada.pdf) are available.

### Software distribution
One foundational part of the infrastructure comes even before installing any software: the distribution mechanism. For this, we use [CVMFS](https://cvmfs.readthedocs.io/en/stable/). This allows any cluster, virtual machine, or event desktop or laptop computer, to access our software stack in a matter of a few minutes. We make this available to our users, as documented [here](https://docs.computecanada.ca/wiki/Accessing_CVMFS). Some users use it for continuous integration, we also use it in virtual clusters in the cloud.

### Compatibility layer
Because we support multiple clusters, we have to assume that they may not run exactly the same operating system, or don't have exactly the same system packages installed. To avoid issues, we therefore minimize the OS dependencies to an absolute minimum. Our stack contains all system libraries down to `glibc` and the Linux loader. Our only dependencies are the kernel and the hardware drivers. For this layer, we have used the [Nix](https://github.com/NixOS/nix) package manager, but we are now moving toward using [Gentoo Prefix](https://wiki.gentoo.org/wiki/Project:Prefix) instead.

### Scientific layer and EasyBuild
For every scientific software, our staff go through a process that involves installing it through EasyBuild, and then deploying it to CVMFS. As of June 2020, we have over 800 different software packages installed. When combined with version of the software, version of the compiler/MPI/CUDA, and CPU architectures, we have respectively over 1,600, 3,200 and 6,000 combinations of builds.


## Usage of EasyBuild within Compute Canada
To illustrate EasyBuild's flexibility, in this section, we highlight some of the peculiarities of EasyBuild's usage within Compute Canada.

### Filtering out dependencies
Compute Canada is using EasyBuild to install *all* packages that you would not normally find installed in an OS (i.e. through `yum` or `apt-get`). However, because we provide the compatibility layer, many of the libraries that can be installed through EasyBuild are filtered out. This includes for example `binutils`, ` Automake`, `flex`, etc. This is configured through our [EasyBuild configuration file](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/config.cfg#L13).

### Custom toolchains
Before deploying our new infrastructures, virtually all sites had a long history of using the Intel or GNU Compilers, OpenMPI, and Intel MKL, with very little usage of OpenBLAS or Intel MPI. Therefore, our primary toolchains are based on those tools - i.e. variations on the `iomkl` or `gomkl` toolchains, which are not the ones mostly used by upstream EasyBuild (which are the *common* `foss` and `intel` toolchains). We therefore make a heavy use of the `--try-toolchain` option of EasyBuild, to use upstream recipes but with our preferred toolchains.

### Custom module naming scheme
We use a lower-case hierarchical module naming scheme which also includes the CPU architecture that a software is built for as part of the hierarchy. Our module naming scheme also completely drops `versionsuffix`. If we need to have different flavors of a given recipe, we instead use `modaltsoftname` to add the flavor to the name of the software package. This is enabled through [this Python module](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/master/SoftCCHierarchicalMNS.py), which implements our custom module naming scheme.

## Using `RPATH` and disabling `LD_LIBRARY_PATH`
Our compatibility layer has a modified linker which ensures that `RPATH` is added to every shared library and executable that is compiled. This applies to both EasyBuild's builds and users' builds. We therefore filter out the `LD_LIBRARY_PATH` from the modules. This is specified in our [EasyBuild configuration file](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/config.cfg#L15).

### Usage of hooks
We make a rather intensive usage of hooks. For example, we use them to

* [inject specific configure options to our OpenMPI builds](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/cc_hooks.py#L256)
* add [compiler](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/cc_hooks.py#L460) and [MPI](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/cc_hooks.py#L477) footers to the modules
* [split the installation of the Intel compiler into redistributable and non-redistributable parts](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/cc_hooks.py#L485)
* [strip down the installation of Python to a small set of Python packages](https://github.com/ComputeCanada/easybuild-computecanada-config/blob/605bbc14d9312049afa1937090d2ed0d64f8169c/cc_hooks.py#L578)

## Python specific customizations
Compute Canada makes heavy usage of the `multi_deps` feature for Python package installations. This allows us to install single modules that support multiple versions of Python. We also tend to install Python wrappers alongside the primary module when there is a primary module. For example, we install `PyQt` alongside `Qt`, in the same module.

For most Python packages however, we do not install them as modules. We instead provide a large repository of binary Python packages that we have compiled against our modules, and instruct our users to install them in [virtual environments](https://docs.computecanada.ca/wiki/Python#Creating_and_using_a_virtual_environment). The vast majority of Python packages can be built as Python wheels with a common script, with minor differences such as loading a prerequisite module or installing a dependency. This script is available on our [Github wheels_builder repository](https://github.com/ComputeCanada/wheels_builder/).

---

[*next: The EasyBuild community*](community.md) - [*(back to overview page)*](index.md)
