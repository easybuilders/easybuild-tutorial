# EasyBuild Workshop: Practical info

<p align="center"><a href="https://easybuild.io"><img src="../../img/easybuild_logo_alpha.png" alt="EasyBuild logo" width="300px"/></a></p>

This page explains how you can prepare for the EasyBuild tutorial
that takes place just after the [EUM'23](https://easybuild.io/eum23/).

## Prepared environment

Tutorial attendees will be able to log in to a prepared environment
where they can follow along with hands-on examples, or solve the
tutorial exercises.

You can create an account for the prepared environment by filling
out the [account form](https://mokey.eum23.learnhpc.eu/auth/signup).
The accounts will _not_ be approved until the day before the event, so
**please remember to keep a record of your username and password**.

Once the account is approved, you will be able to access the system
at [https://eum23.learnhpc.eu/](https://eum23.learnhpc.eu/), or via `ssh`:

    ssh eum23.learnhpc.eu

??? tip "Reproducing the tutorial environment at home (after the workshop): (click to show steps)"

    !!! warning

        These steps might need to be tweaked for your system. Please reach out to us on Slack if you run into problems.

    The prepared environment remains available for a few days during the conference. If after the conference
    you want to go through the tutorial and try the exercises on your home system, you can follow
    this procedure while working your way through the tutorial:

    -   EasyBuild has a set of [requirements](https://docs.easybuild.io/en/latest/Installation.html#requirements)
        and [dependencies](https://docs.easybuild.io/en/latest/Installation.html#dependencies)
        that it expects to find on your system (such as `make`, `patch`,... as well as a system C++ compiler to be
        able to build GCC), you will need to ensure that these are available. 

    -   [Install EasyBuild](installation.md). We recommend to use the 
        ["Installing EasyBuild with EasyBuild" method](../easybuild-installation/#method-2-installing-easybuild-with-easybuild),
        but choosing a different directory for the `--prefix` argument. That directory should
        then be used wherever `/easybuild` is used in the tutorial text.

        Assume that the installation directory is stored in `$_PREFIX_`. The series of commands to install
        EasyBuild and make the EasyBuild module available are
        ```shell
        module unuse $MODULEPATH
        export EB_TMPDIR=/tmp/$USER/eb_tmp
        python3 -m pip install --ignore-installed --prefix $EB_TMPDIR easybuild
        export PATH=$EB_TMPDIR/bin:$PATH
        export PYTHONPATH=$(/bin/ls -rtd -1 $EB_TMPDIR/lib*/python*/site-packages | tail -1):$PYTHONPATH
        export EB_PYTHON=python3
        eb --install-latest-eb-release --prefix $_PREFIX_
        module use $_PREFIX_/modules/all
        ```
        The first line (the `module unuse` command) cleans the environment and assures that modules already
        installed on the system will not screw up the installation that you intend to do.

        Alternatively, when newer versions of EasyBuild are available than the version 4.7.1 used to prepare
        this tutorial, the line with `eb --install-latest-eb-release` can be replaced with
        ```shell
        eb EasyBuild-4.7.1.eb --prefix $_PREFIX_
        ```
        to install the version of EasyBuild used for the preparation of this tutorial.

    -   Install the software needed for the tutorial in the same directory structure as EasyBuild.
        This can be done in a single command (after loading the EasyBuild module). The workings of this command is explained in the
        ["Configuring EasyBuild"](easybuild-configuration.md) and ["Basic usage of EasyBuild"](easybuild-basic_usage.md)
        sections:
        ```shell
        module load EasyBuild
        eb CMake-3.24.3-GCCcore-12.2.0.eb SciPy-bundle-2023.02-gfbf-2022b.eb --prefix $_PREFIX_ --robot
        ```

    Note that the installation can take a few hours and that some steps require a lot of CPU time (e.g., the testing
    done when installing SciPy), so you may not be able to do it on the login nodes of a cluster.

---

---

[*next: Introduction*](easybuild-introduction.md) - [*(back to overview page)*](index.md)