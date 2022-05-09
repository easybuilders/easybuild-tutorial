# LUMI software stacks (technical)

*[[back: The Cray Programming Environment]](1_03_CPE.md)*

---

The user-facing documentation on how to use the LUMI software stacks is
available in [the LUMI documentation](https://docs.lumi-supercomputer.eu/computing/softwarestacks/).
On this page we focus more on the technical implementation behind it.

---

# An overview of LUMI

LUMI has different node types providing compute resources:

-   LUMI has 16 login nodes, though many of those are reserved for special purposes and not
    available to all users. These login nodes have a zen2 CPU. These nodes have a SlingShot 10
    interconnect.
-   There are 1536 regular CPU compute nodes in a partition denoted as LUMI-C. These
    compute nodes have a zen3 CPU and run a reduced version of SUSE Linux optimised
    by Cray to reduce OS jitter. These nodes will in the future be equipped with a 
    SlingShot 11 interconnect card.
-   There are 2560 GPU compute nodes in a partition denoted as LUMI-G. These nodes have
    a single zen3-based CPU with optimised I/O die linked to 4 AMD MI250X GPUs. Each node
    has 4 SlingShot 11 interconnect cards, one attached to each GPU.
-   The interactive data analytics and visualisation partition is really two different partitions 
    from the software point-of-view:
    -   8 nodes are CPU-only but differ considerably from the regular compute nodes,
        not only in the amount of memory. These nodes are equipped with zen2 CPUs
        and in that sense comparable to the login nodes. They also have local SSDs
        and are equipped with SlingShot 10 interconnect cards (2 each???)
    -   8 nodes have zen2 CPUs and 8 NVIDIA A40 GPUs each, and have 2 SlingShot 10
        interconnect cards each.
-   The early access platform (EAP) has 14 nodes equiped with a single 64-core
    zen2 CPU and 4 AMD MI100 GPUS. Each node has a single SlingShot 10 interconnect
    and also local SSDs.

SlingShot 10 and SlingShot 11 are different software-wise. SlingShot 10 uses a
Mellanox CX5 NIC that support both OFI and UCX, and hence can also use the
UCX version of Cray MPICH. SlingShot 11 uses a NIC code-named Cassini and
supports only OFI with an OFI provider specific for the Cassini NIC. However,
given that the nodes that are equipped with SlingShot 10 cards are not meant
to be used for big MPI jobs, we build our software stack solely on top of 
libfabric and Cray MPICH.


---

## CrayEnv and LUMI modules

On LUMI, two types of software stacks are currently offered:

  - ``CrayEnv`` (module name) offers the Cray PE and enables one to use
    it completely in the way intended by HPE-Cray. The environment also offers a
    limited selection of additional tools, often in updated versions compared to
    what SUSE Linux, the basis of the Cray Linux environment, offers. Those tools
    are installed and managed via EasyBuild. However, EasyBuild is not available
    in that partition.

    It also rectifies a problem caused by the fact that there is only one 
    configuration file for the Cray PE on LUMI, so that starting a login shell
    will not produce an optimal set of target modules for all node types.
    The ``CrayEnv`` module recognizes on which node type it is running and
    (re-)loading it will trigger a reload of the recommended set of target
    modules for that node.

  - ``LUMI`` is an extensible software stack that is mostly managed through
    [EasyBuild][easybuild]. Each version of the LUMI software stack is based on
    the version of the Cray Programming Environment with the same version
    number.

    A deliberate choice was made to only offer a limited number of software
    packages in the globally installed stack as the setup of redundancy on LUMI
    makes it difficult to update the stack in a way that is guaranteed to not
    affect running jobs and as a large central stack is also hard to manage, especially
    as we expect frequent updates to the OS and compiler infrastructure in 
    the first years of operation.
    However, the EasyBuild setup is such that users can easily install
    additional software in their home or project directory using EasyBuild build
    recipes that we provide or they develop, and that software will fully
    integrate in the central stack (even the corresponding modules will be made
    available automatically).

    Each ``LUMI`` module will also automatically activate a set of application 
    modules tuned to the architecture on which the module load is executed. To 
    that purpose, the ``LUMI`` module will automatically load the ``partition``
    module that is the best fit for the node. After loading a version of the
    ``LUMI`` module, users can always load a different version of the ``partition``
    module.

Note that the ``partition`` modules are only used by the ``LUMI`` module. In the
``CrayEnv`` environment, users should overwrite the configuration by loading their
set of target modules after loading the ``CrayEnv`` module.


---

## The ``partition`` module

The ``LUMI`` module currently supports five partition modules, but that number may
be reduced in the future:

| Partition         | CPU target            | Accelerator                 |
|:------------------|-----------------------|:----------------------------|
| ``partition/L``   | ``craype-x86-rome``   | ``craype-accel-host``       |
| ``partition/C``   | ``craype-x86-milan``  | ``craype-accel-host``       |
| ``partition/G``   | ``craype-x86-trento`` | ``craype-accel-amd-gfx90a`` |
| ``partition/D``   | ``craype-x86-rome``   | ``craype-accel-nvidia80``   |
| ``partition/EAP`` | ``craype-x86-rome``   | ``craype-accel-amd-gfx908`` |

All ``partition`` modules also load `craype-network-ofi``.

``pattition/D`` may be dropped in the future as it seems we have no working CUDA setup
and can only use the GPU nodes in the LUMI-D partition for visualisation and not with CUDA.

Furthermore if it would turn out that there is no advantage in optimizing for Milan
specifically, or that there are no problems at all in running Milan binaries on Rome 
generation CPUs, ``partition/L`` and ``partition/C`` might also be united in a single 
partition.






    
---

*[[next: Terminology]](1_05_terminology.md)*

