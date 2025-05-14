# Managing EasyBuild-installed software on LUMI

## Repositories and their function

TODO


## Creating and installing a new release of the LUMI software stack

TODO not complete

-   We work as much as possible with pull requests so that there is a better history of when 
    packages were added or modified in the software stack and library.

    It also enables someone to check the layout of the easyconfigs and see if they more or less
    follow the guidelines and for packages centrally installed, it makes it easy to see when there
    is something new that needs to be installed.

-   The central software stack is no playground. Installations in there are tested as much as possible
    in a copy of the stack. Once a module is in there, it cannot be changed as it could disrupt work
    of users who are using that module at that time. This is one of the reasons why we prefer to have
    software as much as possible installed by the users in their account: They only need to talk to their
    project members to agree when a package can be changed.

    The stack exists in 5 copies on LUMI

    -   The master copy is in `/pfs/lustref1/appl/lumi` and is available on `/appl/lumi` only on
        uan06. This implies that currently all software installation in the central stack should
        be done on uan06 as we want to make sure that paths that may get hard-coded in scripts
        and binaries use `/appl/lumi` and do not refer to a specific file system.

    -   The copies used on the login nodes and compute nodes are in `/pfs/lustrepX/appl/lumi`, with X 1, 2, 3 or 4.

    The `*/appl/lumi` directories can be written by everybody in the `appl_lumi`(462000009) project.
    Everybody in that project should use uan06 as little as possible as one may very well 
    accidentally damage the software stack. Some applications want to upgrade themselves - we keep them
    out of the stack but may make errors there - or when using Python, it may decide to install
    additional packages in a directory that happens to be in the Python search path. The number of 
    people in that group should be as small as possible, basically the maintainers of the software
    stacks installed in `/appl/lumi` and their backups and noone else.

    Deleting a package from the central stack is done in multiple steps:

    1.  Often first a warning via the Lmod `admin.lst` file
    2.  Delete the module
    3.  And a few weeks later, delete the software from the central stack

    Every synchronisation of the central stack can take more than one hour, and the order in which 
    various directories are synchronised is well thought out so that a module will never appear on
    the system if the software is not first made available on all 4 copies.

-   Every release is currently prepared on a laptop. It has a directory containing the following
    repositories:

    -   [LUMI-SoftwareStack](https://github.com/Lumi-supercomputer/LUMI-SoftwareStack)

    -   [LUMI-EasyBuild-contrib](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib)

    -   [LUMI-EasyBuild-containers](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-containers)

    -   [LUMI-EasyBuild-docs](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-docs)

    -   tags: Contains the tags used with each release

        TODO: Restructure and bring the relevant part to lumi-supercomputer

-   Before creating a new release, add the release name (YYYyMMDD) to the 
    `docs/whats_new.md` with a description of the changes/additions. This page
    will also appear in the LUMI Software Library.

Also TODO: Rework the script used to create a release and include in LUMI-SoftwareStack rather
then a totally separate private repository that contains other scripts also that have little to
do with LUMI.


## Documenting the software stack on LUMI

### LUMI Software Library

The LUMI Software Library is built automatically from a number of files in markdown syntax.
The script is very naive when it tries to renumber the title levels. It goes wrong when a
code block is included that starts on the first column and contains lines starting with `#`.
The workaround is to indent such a code block with one space.

Files stored with the EasyConfig:

-   `USER.md`: Optional, extra information for regular users.

-   `LICENSE.md`: Highly preferred. Information on the license of the package.

-   `README.md`: Technical information:
    -   Where can we find the package?

    -   Is there already support in EasyBuild or Spack?

    -   Overview of our past EasyConfigs and how they were built.
  
        Never delete information from this, or you'd have to rewrite the first entry
        in the new list to contain all previous elements that are necessary to understand the EasyConfig.


### LUMI-SoftwareStack repository

The repository contains a `docs` subdirectory with markdown-based documentation. 

The `docs/config` subdirectory contains the `mkdocs.yml` file for the documentation,
a `Makefile` to test the documentation and the `requirements.txt` file for the mkdocs setup
in Python.

The documentation is updated automatically in `github.io` when a push to the main branch is
made in the repository and can be accessed on
[lumi-supercomputer.github.io/LUMI-SoftwareStack/](https://lumi-supercomputer.github.io/LUMI-SoftwareStack/).


### Documenting the actual installation process on LUMI uan06

Each installation done on LUMI uan06 is carefully documented on the
["Change log for the software stack in /appl/lumi" page in the LUST eduuni wiki](https://wiki.eduuni.fi/spaces/CSCLUST/pages/266410121/Change+log+for+the+software+stack+in+appl+lumi).

This is done *before* actually doing the installation and has been tested as much as possible on a copy of the software stack
(currently a personal copy, could be a LUST one in 462000008).


*[[Next: EasyBuild tips & tricks]](4_02_tips_and_tricks.md)*

