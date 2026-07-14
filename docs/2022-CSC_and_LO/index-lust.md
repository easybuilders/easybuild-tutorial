<<<<<<< HEAD
# EasyBuild tutorial for CSC and the LUMI consortium
=======
# EasyBuild tutorial for LUST

Overview page of the introductory tutorial on [EasyBuild](https://easybuild.io) for the CSC
and Local Organizations who want to contribute to the LUMI EasyBuild setup.
>>>>>>> 5573462b (Initial commit, already contains the structure to work on the first tutorial.)

This tutorial is based extensively on the more generic EasyBuild tutorials build by
the EasyBuild community and maintained on
[the EasyBuild tutorial site](https://easybuilders.github.io/easybuild-tutorial/).
See that site for [credits to the contributors of those tutorials](https://easybuilders.github.io/easybuild-tutorial/#contributors).

<<<<<<< HEAD
## Scope

This is an introductory tutorial to [EasyBuild](https://easybuild.io),
a command line tool for installing (scientific) software on High Performance Computing (HPC) systems.
This tutorial is specifically for EasyBuild as implemented on [LUMI](https://lumi-supercomputer.eu)
and has been developed for CSC and the Local Organisations within the LUMI consortium. Yet
much of the material is useful to a broader community of EasyBuild users on Cray systems
or even EasyBuild users in general.
For more generic EasyBuild tutorials, see the [EasyBuild tutorial site](https://easybuilders.github.io/easybuild-tutorial/).

This tutorial aims to explain the core concepts of EasyBuild,
get you started with using it, make you familiar with some of the features it provides,
and show how it is used on LUMI to maintain the central software stacks and offer the users
an easy environment to install packages on top of the central stack and thus create their own
customised environment.

Through hands-on exercises and demos, you will learn how EasyBuild can help you
to get scientific software installed in an efficient way.


## Intended audience

This tutorial is primarily intended for people new to EasyBuild, but even if you're already familiar
with the project it could be interesting to step through it.

Our main target audience includes:

-   application experts in LUST and the local organizations who want to contribute to the
    software stack on LUMI or support their users;
-   developers who want to make their developments available to LUMI users;
-   advanced users who want to customize available build recipes or develop their own recipes.


## Prerequisites

We expect you to be (a little bit) familiar with:

-   using a Linux command line interface;
-   the (absolute) basics of compiling software from source.

EasyBuild requires:

-   GNU/Linux (any distribution),
-   Python 2.7 or 3.5+, though a fairly recent version of Python 3 is highly recommended,
-   an environment modules tool (see the ``module`` command). On LUMI we use [Lmod](https://lmod.readthedocs.io), 
    a modern environment modules tool implemented in Lua.

However, the LUMI version of the tutorial is currently specifically for the Cray Programming Environment which is not
freely available, so unless you have access to a system with this environment you cannot really do local development.


## Contents

- [Part I: **Introduction to EasyBuild on Cray systems**](1_Intro/index.md)
    -   [What is EasyBuild?](1_Intro/1_01_what_is_easybuild.md)
    -   [The Lmod module system](1_Intro/1_02_Lmod.md)
    -   [The HPE Cray Programming Environment](1_Intro/1_03_CPE.md)
    -   [LUMI software stacks](1_Intro/1_04_LUMI_software_stack.md)
    -   [Terminology](1_Intro/1_05_terminology.md)
    -   [Installation](1_Intro/1_06_installation.md)
    -   [Configuration](1_Intro/1_07_configuration.md)
    -   [Basic usage](1_Intro/1_08_basic_usage.md) *(hands-on)*
- [Part II: **Using EasyBuild**](2_Using/index.md)
    -   [Troubleshooting](2_Using/2_01_troubleshooting.md) *(hands-on)*
    -   [Creating easyconfig files](2_Using/2_02_creating_easyconfig_files.md) *(hands-on)*
    -   [Using external modules from the Cray PE](2_Using/2_03_external_modules.md)
    -   [Implementing easyblocks](2_Using/2_04_implementing_easyblocks.md) *(hands-on)*
- [Part III: **Advanced topics**](3_Advanced/index.md)
    -    [Using EasyBuild as a library](3_Advanced/3_01_easybuild_library.md)
    -    [Using hooks to customise EasyBuild](3_Advanced/3_02_hooks.md)
    -    [Submitting installations as Slurm jobs](3_Advanced/3_03_slurm_jobs.md)
    -    [Module naming schemes (incl. hierarchical)](3_Advanced/3_04_module_naming_schemes.md)
    -    [GitHub integration to facilitate contributing to EasyBuild](3_Advanced/3_05_github_integration.md)
- [**Additional reading**](4_00_additional_reading.md)
=======
## Contents

TODO






## OLD TEXT

- [Part I: **Introduction to EasyBuild**](part1_intro.md) *(Tue March 9th 2021, 9am-12 CET)*
    * [What is EasyBuild?](what_is_easybuild.md)
    * [Terminology](terminology.md)
    * [Installation](installation.md) *(hands-on)*
    * [Configuration](configuration.md) *(hands-on)*
    * [Basic usage](basic_usage.md) *(hands-on)*
- [Part II: **Using EasyBuild**](part2_using.md) *(Tue March 23rd 2021, 9am-12 CET)*
    * [Troubleshooting](troubleshooting.md) *(hands-on)*
    * [Creating easyconfig files](creating_easyconfig_files.md) *(hands-on)*
    * [Implementing easyblocks](implementing_easyblocks.md) *(hands-on)*
- [Part III: **Advanced topics**](part3_advanced.md) *(Tue March 30th 2021, 9am-12 CEST)*
    * [Using EasyBuild as a library](easybuild_library.md) *(hands-on)*
    * [Using hooks to customise EasyBuild](hooks.md) *(hands-on)*
    * [Submitting installations as Slurm jobs](slurm_jobs.md) *(hands-on)*
    * [Module naming schemes (incl. hierarchical)](module_naming_schemes.md) *(hands-on)*
    * [GitHub integration to facilitate contributing to EasyBuild](github_integration.md) *(hands-on)*
- [Part IV: **EasyBuild on Cray systems**](part4_cray.md) *(Friday June 18th 2021, 09-12 CEST)*
    * [Introduction to Cray Programming Environment](cray/introduction.md) *(hands-on)*
    * [Cray External Modules](cray/external_modules.md) *(hands-on)*
    * [Cray Custom Toolchains](cray/custom_toolchains.md) *(hands-on)*
    * [EasyBuild at CSCS](cray/easybuild_at_cscs.md) *(hands-on)*
>>>>>>> 5573462b (Initial commit, already contains the structure to work on the first tutorial.)
