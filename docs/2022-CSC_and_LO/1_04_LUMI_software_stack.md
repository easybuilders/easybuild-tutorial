# LUMI software stacks (technical)

*[[back: The Cray Programming Environment]](1_03_CPE.md)*

---

The user-facing documentation on how to use the LUMI software stacks is
avialable in [the LUMI documentation](https://docs.lumi-supercomputer.eu/computing/softwarestacks/).
On this page we focus more on the technical implementation behind it.

---

# An overview of LUMI

LUMI has different node types providing compute resources:

-   LUMI has 16 login nodes, though many of those are reserved for special purposes and not
    available to all users. TODO


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
    affect running jobs and as a large central stack is also hard to manage.
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

The ``LUMI`` module currently supports four partition modules, but that number may
be reduced in the future:

| Partition       | CPU target            | Accelerator                 |
|:----------------|-----------------------|:----------------------------|
| ``partition/L`` | ``craype-x86-rome``   | ``craype-accel-host``       |
| ``partition/C`` | ``craype-x86-milan``  | ``craype-accel-host``       |
| ``partition/G`` | ``craype-x86-trento`` | ``craype-accel-amd-gfx90a`` |
| ``partition/D`` | ``craype-x86-rome``   | ``craype-accel-nvidia80``   |

All ``partition`` modules also load `craype-network-ofi``.

``pattition/D`` may be dropped in the future as it seems we have no working CUDA setup
and can only use the GPU nodes in the LUMI-D partition for visualisation and not with CUDA.

Furthermore if it would turn out that there is no advantage in optimizing for Milan
specifically, or that there are no problems at all in running Milan binaries on Rome 
generation CPUs, ``partition/L`` and ``partition/C`` might also be united in a single 
partition.






    
---

*[[next: Terminology]](1_05_terminology.md)*

