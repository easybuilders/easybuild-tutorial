# Cray External Modules

---

## Cray Scientific and Math Library

Installing software with EasyBuild is as easy as specifying to the **`eb` command** what we
want to install, and then sitting back to enjoy a coffee or tea (or whatever beverage you prefer).

This is typically done by **specifying the name of one or more easyconfig files**, often combined
with the `--robot` option to let EasyBuild also install missing dependencies.
  
It is recommended to first assess the current situation before letting EasyBuild install the software,
and to check which **dependencies** are already installed and which are still missing. In addition,
you may want to inspect the specifics of the **installation procedure** that will be performed by EasyBuild,
and ensure that the active EasyBuild configuration is what it should be.

---

## Third party libraries

Letting EasyBuild know what should be installed can be done by specifying one or more easyconfig files,
which is also the most common way. Alternative methods like using the `--software-name` option won't be
covered in this tutorial, since they are not commonly used.

Arguments passed to the `eb` command, being anything that is *not* an option (which starts with `-` or `--`) or
is a value for a preceding configuration option, are assumed to refer to easyconfig files (with some exceptions).
These could be:

* the *(absolute or relative) path* to an easyconfig file;
* the *name* of an easyconfig file;
* the path to a *directory* containing easyconfig files;

Specified paths to files must of course point to existing files; if not, EasyBuild will print an appropriate error message.

---
