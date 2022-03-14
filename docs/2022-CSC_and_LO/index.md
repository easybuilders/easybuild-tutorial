# EasyBuild tutorial for CSC and the LUMI consortium

This tutorial is based extensively on the more generic EasyBuild tutorials build by
the EasyBuild community and maintained on
[the EasyBuild tutorial site](https://easybuilders.github.io/easybuild-tutorial/).
See that site for [credits to the contributors of those tutorials](https://easybuilders.github.io/easybuild-tutorial/#contributors).

## Scope

This is an introductory tutorial to [EasyBuild](https://easybuild.io),
a command line tool for installing (scientific) software on High Performance Computing (HPC) systems.
These tutorials are specifically for EasyBuild as implemented on [LUMI](https://lumi-supercomputer.eu)
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

-   Application experts in LUST and the local organizations who want to contribute to the
    software stack on LUMI or support their users
-   Developers who want to make their developments available to LUMI users
-   Advanced users who want to customize available build recipes or develop their own recipes


## Prerequisites

We expect you to be (a little bit) familiar with:

-   using a Linux command line interface
-   the (absolute) basics of compiling software from source

EasyBuild requires:

-   GNU/Linux (any distribution)
-   Python 2.7 or 3.5+
-   an environment modules tool (see the ``module`` command). On LUMI we use [Lmod](https://lmod.readthedocs.io), 
    a modern environment modules tool implemented in Lua.

However, the LUMI version of the tutorial is currently specifically for the Cray Programming Environment which is not
freely available, so unless you have access to a system with this environment you cannot really do local development.


## Contents

- [Part I: **Introduction to EasyBuild on Cray systems**](1_00_part1_intro.md)
    -   [What is EasyBuild?](1_01_what_is_easybuild.md)
    -   [The Lmod module system](1_02_Lmod.md)
    -   [The HPE Cray Programming Environment](1_03_CPE.md)
    -   [Terminology](1_04_terminology.md)
    -   [Installation](installation.md) *(hands-on)*
    -   [Configuration](configuration.md) *(hands-on)*
    -   [Basic usage](basic_usage.md) *(hands-on)*



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
