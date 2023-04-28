# Getting Access to EESSI

To get access to EESSI, it suffices to have [CernVM-FS](https://cernvm.cern.ch/fs/) installed, and make it aware
of the EESSI repository.

## Is EESSI accessible?

EESSI can be accessed via [a native (CernVM-FS) installation](#native-installation),
or via [a container that includes CernVM-FS](#eessi-container).

Before you look into these options, check if EESSI is already accessible on your system.

Run the following command:
``` { .bash .copy }
ls /cvmfs/pilot.eessi-hpc.org
```

!!! note

    This ``ls`` command may take a couple of seconds to finish, since CernVM-FS may need to download
    or update the metadata for that directory.

If you see output like shown below, **you already have access to EESSI on your system**. :tada:
```
host_injections  latest  versions
```

For starting to use EESSI, continue reading about
[Setting up environment](eessi-usage.md#setting-up-environment).

If you see an error message as shown below, **EESSI is not yet accessible on your
system**.
```
ls: /cvmfs/pilot.eessi-hpc.org: No such file or directory
```
No worries, you don't need to be a :mage: to get access to EESSI.

Continue reading about the [Native installation](#native-installation) of EESSI,
or access via the [EESSI container](#eessi-container).

## Native installation

Setting up native access to EESSI, that is a system-wide deployment that does not require workarounds like
[using a container](../eessi_container), requires the installation and configuration of [CernVM-FS](https://cernvm.cern.ch/fs).

This requires **admin privileges**, since you need to install CernVM-FS as an OS package.

The following actions must be taken for a (basic) native installation of EESSI:

* Installing CernVM-FS itself, ideally using the OS packages provided by the CernVM-FS project
  (although installing from source is also possible);
* Installing the EESSI configuration for CernVM-FS, which can be done by installing the ``cvmfs-config-eessi``
  package that we provide for the most popular Linux distributions
  (more information available [here](https://github.com/EESSI/filesystem-layer/));
* Creating a small client configuration file for CernVM-FS (``/etc/cvmfs/default.local``);
  see also the [CernVM-FS documentation](https://cvmfs.readthedocs.io/en/stable/cpt-quickstart.html#create-default-local).

The good news is that all of this only requires a handful commands :astonished: :

=== "RHEL-based Linux distributions"

    ``` { .bash .copy }
    # Installation commands for RHEL-based distros like CentOS, Rocky Linux, Almalinux, Fedora, ...

    # install CernVM-FS
    sudo yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
    sudo yum install -y cvmfs

    # install EESSI configuration for CernVM-FS
    sudo yum install -y https://github.com/EESSI/filesystem-layer/releases/download/latest/cvmfs-config-eessi-latest.noarch.rpm

    # create client configuration file for CernVM-FS (no squid proxy, 10GB local CernVM-FS client cache)
    sudo bash -c "echo 'CVMFS_CLIENT_PROFILE="single"' > /etc/cvmfs/default.local"
    sudo bash -c "echo 'CVMFS_QUOTA_LIMIT=10000' >> /etc/cvmfs/default.local"

    # make sure that EESSI CernVM-FS repository is accessible
    sudo cvmfs_config setup
    ```

=== "Debian-based Linux distributions"

    ``` { .bash .copy }
    # Installation commands for Debian-based distros like Ubuntu, ...

    # install CernVM-FS
    sudo apt-get install lsb-release
    wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
    sudo dpkg -i cvmfs-release-latest_all.deb
    rm -f cvmfs-release-latest_all.deb
    sudo apt-get update
    sudo apt-get install -y cvmfs

    # install EESSI configuration for CernVM-FS
    wget https://github.com/EESSI/filesystem-layer/releases/download/latest/cvmfs-config-eessi_latest_all.deb
    sudo dpkg -i cvmfs-config-eessi_latest_all.deb

    # create client configuration file for CernVM-FS (no squid proxy, 10GB local CernVM-FS client cache)
    sudo bash -c "echo 'CVMFS_CLIENT_PROFILE="single"' > /etc/cvmfs/default.local"
    sudo bash -c "echo 'CVMFS_QUOTA_LIMIT=10000' >> /etc/cvmfs/default.local"

    # make sure that EESSI CernVM-FS repository is accessible
    sudo cvmfs_config setup
    ```

!!! note

    :point_up: The commands above only cover the basic installation of EESSI.

    This is good enough for an individual client, or for testing purposes,
    but for a production-quality setup you should also set up a Squid proxy cache.

    For large-scale systems, like an HPC cluster, you should also consider setting up your own CernVM-FS Stratum-1 mirror server.

    For more details on this, please refer to the
    [*Stratum 1 and proxies section* of the CernVM-FS tutorial](https://cvmfs-contrib.github.io/cvmfs-tutorial-2021/03_stratum1_proxies/).

## EESSI client container

The `eessi_container.sh` script provides a very easy yet versatile means
to access EESSI.

This page guides you through several example scenarios
illustrating the use of the script.

### Prerequisites

- Apptainer 1.0.0 (_or newer_), or Singularity 3.7.x
    - Check with `apptainer --version` or `singularity --version`
    - Support for the `--fusemount` option in the ``shell`` and ``run`` subcommands is required
- Git
    - Check with `git --version`

### Preparation

Clone the [`EESSI/software-layer`](https://github.com/EESSI/software-layer.git)
repository and change into the `software-layer` directory by running these commands:

``` { .bash .copy }
git clone https://github.com/EESSI/software-layer.git
cd software-layer
```

### Quickstart

Run the `eessi_container` script (from the ``software-layer`` directory) to start a shell session in the EESSI container:

``` { .bash .copy }
./eessi_container.sh
```

!!! Note
    Startup will take a bit longer the first time you run this because the container image is downloaded and converted.

You should see output like
```
Using /tmp/eessi.abc123defg as tmp storage (add '--resume /tmp/eessi.abc123defg' to resume where this session ended).
Pulling container image from docker://ghcr.io/eessi/build-node:debian11 to /tmp/eessi.abc123defg/ghcr.io_eessi_build_node_debian11.sif
Launching container with command (next line):
singularity -q shell --fusemount container:cvmfs2 pilot.eessi-hpc.org /cvmfs/pilot.eessi-hpc.org /tmp/eessi.abc123defg/ghcr.io_eessi_build_node_debian11.sif
CernVM-FS: pre-mounted on file descriptor 3
Apptainer> CernVM-FS: loading Fuse module... done
fuse: failed to clone device fd: Inappropriate ioctl for device
fuse: trying to continue without -o clone_fd.

Apptainer>
```
!!! Note
    You may have to press enter to clearly see the prompt as some messages
    beginning with `CernVM-FS: ` have been printed after the first prompt
    `Apptainer> ` was shown.

In this environment, you should be able to access the EESSI pilot repository:

``` { .bash .copy }
ls /cvmfs/pilot.eessi-hpc.org
```

More information on using the `eessi_container` script is available in the [EESSI documentation](https://eessi.github.io/docs/getting_access/eessi_container/).


---

To start using EESSI, see [Using EESSI](eessi-usage.md).



[*next: Using EESSI*](eessi-usage.md) - [*(back to overview page)*](index.md)
