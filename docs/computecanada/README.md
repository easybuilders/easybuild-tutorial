# Compute Canada
Compute Canada is a national organization in Canada. Its role is to coordinates the work of regions and institutions to make advanced computing research infrastructures (clusters, cloud, data repositories) available to Canadian academic researchers. It is similar to XSEDE in the USA. 

## Staff
Compute Canada has around 200 full time equivalent staff located across almost 40 different institutions, in all provinces of Canada. 

## User base 
Compute Canada's user base is composed of about 15000 users in all disciplines, with a growth of about 20% per year. 

## Resources 
Compute Canada and its partners manage 4 main clusters, and 1 main openstack cloud. [Cedar](https://docs.computecanada.ca/wiki/Cedar) is a general purpose cluster that uses Intel OmniPath, has two generations of GPUs (P100 and V100), and three generations of CPUs (Broadwell, Skylake and Cascade Lake), for a total of nearly 100k cores and 1400 GPUs. [Graham](https://docs.computecanada.ca/wiki/Graham) is an InfiniBand cluster with similar characteristics as Cedar, but half its size. [Béluga](https://docs.computecanada.ca/wiki/B%C3%A9luga/en) is our third general purpose cluster, also using InfiniBand, with V100 GPUs and Skylake CPUs. [Niagara](https://docs.computecanada.ca/wiki/Niagara) is our large parallel cluster, with a dragonfly InfiniBand network technology, and all identical nodes with nearly 80k cores. Finally, [Arbutus](https://docs.computecanada.ca/wiki/Cloud_resources) is our primary OpenStack cloud infrastructure with about 15k cores. 

# Compute Canada software stack
Software installation is amongst the activities that are centralized by Compute Canada. We provide a single user space environment that is available across all of the clusters (all 4 primary clusters, with many legacy clusters also adopting the same environment). This means that users can move across clusters seemlessly, since the same modules are available everywhere. 

For this to happen, especially given the variety of hardware we support, a couple of components are required. These were described in details in the paper presented at PEARC'19, which can be found [here](https://ssl.linklings.net/conferences/pearc/pearc19_program/views/includes/files/pap139s3-file1.pdf).

## Software distribution
One foundational part of the infrastructure comes even before installing any software. It is the distribution mechanism. For this, we use [CVMFS](https://cvmfs.readthedocs.io/en/stable/). This allows any cluster, virtual machine, or event desktop or laptop computer, to access our software stack in a matter of a few minutes. We make this available to our users, as documented [here](https://docs.computecanada.ca/wiki/Accessing_CVMFS). Some users use it for continuous integration, we also use it in virtual clusters in the cloud. 

## Compatibility layer
Because we support multiple clusters, we have to assume that they may not run exactly the same operating system, or don't have exactly the same system packages installed. To avoid issues, we therefore minimize the OS dependencies to an absolute minimum. Our stack contains all system libraries down to the glibc, and the linux loader. Our only dependencies are the kernel and the hardware drivers. For this layer, we have used the [Nix](https://github.com/NixOS/nix) package manager, but we are now moving toward using [Gentoo Prefix](https://wiki.gentoo.org/wiki/Project:Prefix) instead. 

## Scientific layer and EasyBuild
For every scientific software, our staff go through a process that involves installing it through EasyBuild, then deploying it to CVMFS. As of June 2020, we have over 800 different software packages installed. When combined with version of the software, version of the compiler/MPI/CUDA, and CPU architectures, we have respectively over 1600, 3200 and 6000 combinations of builds. 
