# Practical information (WIP)

Below you can find practical information on the provided resources for this tutorial.


### Slack

There is a dedicated `#tutorial` channel in the EasyBuild Slack to get in touch with the
tutorial organisers, where you can ask questions throughout the tutorial, or ask for help if needed.

To connect, you will need to create an account in the EasyBuild Slack first,
which you can do via [https://easybuild-slack.herokuapp.com/](https://easybuild-slack.herokuapp.com/).

Once you have an account, you can join the EasyBuild Slack via [https://easybuild.slack.com/](https://easybuild.slack.com/), and then join the `#tutorial` channel.


### AWS resources

*(only available during the tutorial in June 2020)*

Access to a shell environment on [AWS Cloud9](https://aws.amazon.com/cloud9/) is provided
for this tutorial.

You should have received an email with connection information if you have registered in time for this tutorial.

***If you did not register and would still like to use AWS Cloud9 for this tutorial,
please contact the tutorial organisers via Slack.***


### Prepared container image

For the purpose of this tutorial, we have prepared a **Docker container**
that you can use to follow the hands-on exercises in a controlled environment.

This container image also includes a software stack that was installed using
EasyBuild, which will come in useful for some of the exercises.

The container is available through the `easybuilders/tutorial` repository on Docker Hub
([https://hub.docker.com/repository/docker/easybuilders/tutorial](https://hub.docker.com/repository/docker/easybuilders/tutorial)), and can be used with both Docker and Singularity.

#### Requirements for using the container images

*(only relevant if you are* ***not*** *using AWS Cloud9)*

* having Docker or Singularity installed
* a processor compatible with software built for Intel Haswell (AVX2 instruction set)

#### Using Docker

If you want to use the prepared container image via Docker,
run the following `docker` command:

```
docker run -ti --rm easybuilders/tutorial:isc20
```


#### Using Singularity

*(not available in AWS environment)*

To use the prepared container image via Singularity,
run the following `singularity` command:

```shell
singularity run --cleanenv --home /tmp/$USER/fakehome docker://easybuilders/tutorial:isc20
```

The additional options are required to:

* `--cleanenv`: start with clean environment
* `--home /tmp/$USER/fakehome`: use (empty) `/tmp/$USER/fakehome` directory as home directory in container

This is mainly to avoid that anything from the host environment or your home directory "leaks" into
the container, which could interfere with the hands-on exercises.
