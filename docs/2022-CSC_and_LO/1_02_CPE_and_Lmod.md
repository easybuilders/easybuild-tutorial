# The HPE Cray Programming Environment and Lmod

*[[back: What is EasyBuild?]](1_01_what_is_easybuild.md)*

---

On LUMI, the main programming environment is the HPE Cray Programming Environment (further abbreviated
as Cray PE). The environment provides several tools, including compilers, communication libraries, 
optmized math libraries and various other libraries, analyzers and debuggers.

The Cray PE is made available through *environment modules* tha allow to select particular versions of 
tools and to configure the environment in a flexible way.

---

## Modules

*Module* is a massively overloaded term in (scientific) software and IT in general
(kernel modules, Python modules, and so on).
In the context of EasyBuild, the term 'module' usually refers to an **environment module (file)**.

[Environment modules](https://en.wikipedia.org/wiki/Environment_Modules_(software)) is a well established concept
on HPC systems: it is a way to specify changes that should be made to one or more
[environment variables](https://en.wikipedia.org/wiki/Environment_variable) in a
[shell](https://en.wikipedia.org/wiki/Shell_(computing))-agnostic way. A module file
is usually written in either [Tcl](https://en.wikipedia.org/wiki/Tcl) or
[Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)) syntax,
and specifies which environment variables should be updated, and how (append,
prepend, (re)define, undefine, etc.) upon loading the environment module.
Unloading the environment module will restore the shell environment to its previous state.

Environment module files are processed via a **modules tool**, of which there
are several conceptually similar yet slightly different implementations.
The oldest module tool still in use today is Environment Modules 3.2, implemented in C and 
supporting module files written in Tcl. After a gap in developement, Xavier Delaruelle of CEA
developed [Environment Modules 4 and 5](https://sourceforge.net/projects/modules/) which is
fully implemented on Tcl. An alternative module tool is [Lmod](https://lmod.readthedocs.io), 
developed by Robert McLay at TACC and implemented in LUA. This tool supports natively LUA
module files but also offers a high degree of compatibility with Tcl-based module files
developed for Environment Modules fia a translation layer and some API translation.

The Cray PE offers a choice between the old-style Environment Modules 3.2 and Lmod, but no
packages or official support for Environment Modules 4 or 5. On LUMI, Lmod was selected as
the module tool. At the user level, Lmod and the various versions of Emvironment Modules
have very simmilar commands for managing the environment, but with different options.
The commands for searching for modules are very different though so if you are not familiar
with Lmod and its commands for users, it is worthwile to read the 
[LUMI documentation page on Lmod](https://docs.lumi-supercomputer.eu/computing/Lmod_modules/).

---

## Lmod features


---

## Cray PE components


---

## Configuring the Cray PE through modules

---

## Further reading


---

*[[next: Terminology]](1_03_terminology.md)*
