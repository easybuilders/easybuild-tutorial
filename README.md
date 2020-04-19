<p align="center"><img src="./docs/img/easybuild_logo_alpha.png" width="300px"/></p>

Welcome to the repository that hosts the sources of the official **[EasyBuild](easybuilders.github.io/easybuild/)
tutorial**, see https://boegel.github.io/easybuild-tutorial.

## Basic info

* tutorial contents are located in ``docs/`` subdirectory

* [Markdown](https://daringfireball.net/projects/markdown) is used as syntax


## Getting started

This tutorial is rendered via [MkDocs](https://www.mkdocs.org/),
which makes it very easy to preview the result of the changes you make locally.

* First, install ``mkdocs``:

      pip install mkdocs

* Start the MkDocs built-in dev-server to preview the tutorial as you work on it:

      mkdocs serve

  Visit http://127.0.0.1:8000 to see the local live preview of the changes you make.

* If you prefer building a static preview you can use ``mkdocs build``,
  which should result in a ``site/`` subdirectory that contains the rendered documentation.


## Automatic updates

The rendered version of this tutorial at https://boegel.github.io/easybuild-tutorial
is automatically updated on every push to the ``master`` branch,
thanks to the GitHub Actions workflow defined in
[``.github/workflows/deploy.yml``](https://github.com/boegel/easybuild-tutorial/blob/master/.github/workflows/deploy.yml).

The [``gh-pages``](https://github.com/boegel/easybuild-tutorial/tree/gh-pages) branch in this repository contains the rendered version.

https://boegel.github.io/easybuild-tutorial will only be updated if the tests pass,
see GitHub Actions workflow defined in
[``.github.workflows/test.yml``](https://github.com/boegel/easybuild-tutorial/blob/master/.github/workflows/test.yml).

**Note**: **do *not* change the files in the ``gh-pages`` branch directly!**

All your changes will be lost the next time the ``master`` branch is updated...
