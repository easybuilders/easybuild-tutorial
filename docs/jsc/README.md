# Juelich Supercomputing Centre

(*author: Alan O'Cais, Juelich Supercomputing Centre)*

## General info

<img src="https://boegel.github.io/easybuild-tutorial/img/jsc.jpg" style="float:right" width="280px"/>

The Juelich Supercomputing Centre 
([https://www.fz-juelich.de/ias/jsc](https://www.fz-juelich.de/ias/jsc/EN)) at 
Forschungszentrum Jülich has been operating the first German supercomputing centre since
1987, and with the Jülich Institute for Advanced Simulation it is continuing the long
tradition of scientific computing at Jülich. JSC operates one of the most powerful
supercomputers in Europe, JUWELS and computing time at the highest performance
level is made available to researchers in Germany and Europe by means of an independent
peer-review process.

### Staff & user base

About 200 experts and contacts for all aspects of supercomputing and simulation sciences
work at JSC. JSC's research and development concentrates on mathematical modelling and
numerical, especially parallel algorithms for quantum chemistry, molecular dynamics and
Monte-Carlo simulations. The focus in the computer sciences is on cluster computing,
performance analysis of parallel programs, visualization, computational steering and
federated data services.

In cooperation with renowned hardware and software vendors like IBM, Intel and ParTec,
JSC meets the challenges that arise from the development of exaflop systems - the
computers of the next supercomputer generation. As a member of the German Gauss Centre
for Supercomputing, the Jülich Supercomputing Centre has coordinated the construction
of the European reseach infrastructure "PRACE - Partnership for Advanced Computing in
Europe" since 2008.

### Resources

Juelich Supercomputing Centre currently manages 3 primary systems (in addition to a
number of other development clusters):

[JUWELS](https://www.fz-juelich.de/ias/jsc/EN/Expertise/Supercomputers/JUWELS/Configuration/Configuration_node.html)
is a milestone on the road to a new generation of ultra-flexible modular supercomputers
targeting a broader range of tasks. It currently has 10.6 (CPU) + 1.7 (GPU) Petaflop per
second peak performance with additional modules to come soon.

[JURECA](https://www.fz-juelich.de/ias/jsc/EN/Expertise/Supercomputers/JURECA/Configuration/Configuration_node.html)
is the precursor system to JURECA with 1.8 (CPU) + 0.44 (GPU) + 5 (KNL) Petaflop per
second peak performance.

[JUSUF](https://www.fz-juelich.de/ias/jsc/EN/Expertise/Supercomputers/JUSUF/Configuration/Configuration_node.html)
combines an HPC cluster and a cloud platform in a single system with homogeneous
hardware such that resources can be flexibly shifted between the partitions. The JUSUF
compute nodes are equipped with two AMD EPYC Rome CPUs, each with 64 cores. One third of
the compute nodes are furthermore equipped with one NVIDIA V100
GPU. The JUSUF cluster partition will provide HPC resources for interactive workloads
and batch jobs. The cloud partition will enable co-location of (web) services with these
resources to enable new workflows and support community platforms.


## Juelich Supercomputing Centre software stack

### Software *Stages*
One foundational part of the infrastructure comes even before installing any software: the distribution mechanism. For this, we use [CVMFS](https://cvmfs.readthedocs.io/en/stable/). This allows any cluster, virtual machine, or event desktop or laptop computer, to access our software stack in a matter of a few minutes. We make this available to our users, as documented [here](https://docs.computecanada.ca/wiki/Accessing_CVMFS). Some users use it for continuous integration, we also use it in virtual clusters in the cloud.

## Usage of EasyBuild within JSC
To illustrate EasyBuild's flexibility, in this section, we highlight some of the peculiarities of EasyBuild's usage within Compute Canada.

### Custom toolchains

### Custom module naming scheme

### Usage of hooks
