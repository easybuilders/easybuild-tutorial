!!! warning
    *(Apr 19th 2020)*<br/>
    **This is very much a work in progress!**<br/>
    Many pages are still empty, that will hopefully change soon...

# Welcome to the official EasyBuild tutorial!

<p align="center"><img src="../img/easybuild_logo_alpha.png" alt="EasyBuild logo" width="300px"/></p>


---

## Scope

This is an introductory tutorial to [EasyBuild](https://easybuilders.github.io/easybuild),
a command line tool for installing (scientific) software on High Performance Computing (HPC) systems.

It aims to explain the core concepts of EasyBuild,
get you started with using it, make you familiar with some of the features it provides,
and show how it is used by large HPC sites to maintain their central software stacks.

Through hands-on exercises and demos, you will learn how EasyBuild can help you
to get scientific software installed in an efficient way.


## Intended audience

This tutorial is primarily intended for people new to EasyBuild, but even if you're already familiar
with the project it could be interesting to step through it.

Our main target audience includes:

* HPC system administrators
* HPC user support team members
* scientific researchers using HPC systems


## Prerequisites

We expect you to be (a little bit) familiar with:

* using a Linux command line interface
* the (absolute) basics of compiling software from source

Required software:

* OS: GNU/Linux (any distribution)
* Python 2.7 or 3.5+
* an environment modules tool (see the ``module`` command)

    * we recommend [Lmod](https://lmod.readthedocs.io), a modern environment modules tool implemented in Lua
    * for more information on the environment modules tools supported by EasyBuild, see [here](https://easybuild.readthedocs.io/en/latest/Installation.html#required-modules-tool)

## Practical information

For the sake of this tutorial, you can:

* use the `#tutorial` channel in the EasyBuild Slack for asking questions or getting help;
* use *AWS Cloud9* for the hands-on exercises;
* use the prepared container image through Docker or Singularity;

Please see [this page](practical_information/README.md) for more details.


## Tutorial contents

1. [Introduction to EasyBuild](introduction/README.md)
*  [Installation](installation/README.md) ``(*)``
*  [Configuration](configuration/README.md) ``(*)``
*  [Basic usage](basic_usage/README.md) ``(*)``
*  [Troubleshooting](troubleshooting/README.md) ``(*)``
*  [Hierarchical module naming schemes](hmns/README.md) ``(*)``
*  [Adding support for additional software](adding_support_software/README.md) ``(*)``
*  [EasyBuild at Jülich Supercomputing Centre](jsc/README.md)
*  [EasyBuild at Compute Canada](computecanada/README.md)
*  [The EasyBuild Community](community/README.md)
*  [Contributing to EasyBuild](contributing/README.md) ``(*)``
*  [Comparison with other tools](comparison_other_tools/README.md)
*  [Getting help](getting_help/README.md)

*(sections indicated with* ``(*)`` *involve hands-on exercises)*

## Contributors

* Maxime Boissonneault ([`@mboisson`](https://github.com/mboisson), [Compute Canada](https://www.computecanada.ca))
* Miguel Dias Costa ([`@migueldiascosta`](https://github.com/migueldiascosta), [National University of Singapore](https://nusit.nus.edu.sg/hpc/))
* Markus Geimer ([`@geimer`](https://github.com/geimer), [Jülich Supercomputing Centre, Germany](https://www.fz-juelich.de/ias/jsc/EN/Home/home_node.html))
* Kenneth Hoste ([`@boegel`](https://github.com/boegel), [HPC-UGent, Belgium](https://www.ugent.be/hpc/en))
* Michael Kelsey ([`@kelseymh`](https://github.com/kelseymh), [Texas A&M University, US](https://hprc.tamu.edu/))
* Christian Kniep ([`@ChristianKniep`](https://github.com/ChristianKniep), [AWS](https://aws.amazon.com))
* Terje Kvernes ([`@terjekv`](https://github.com/terjekv), [University of Oslo, Norway](https://www.uio.no/english/))
* Alan O'Cais ([`@ocaisa`](https://github.com/ocaisa), [Jülich Supercomputing Centre, Germany](https://www.fz-juelich.de/ias/jsc/EN/Home/home_node.html))
* Åke Sandgren ([`@akesandgren`](https://github.com/akesandgren), [Umeå University, Sweden](http://www.umu.se/english/))

## Additional resources

* website: [https://easybuilders.github.io/easybuild](https://easybuilders.github.io/easybuild)
* documentation: [https://easybuild.readthedocs.io](https://easybuild.readthedocs.io)
* GitHub: [https://github.com/easybuilders](https://github.com/easybuilders)
* Slack: [https://easybuild.slack.com](https://easybuild.slack.com) (self-request an invite [here](https://easybuild-slack.herokuapp.com))
* mailing list: [https://lists.ugent.be/wws/subscribe/easybuild](https://lists.ugent.be/wws/subscribe/easybuild)
