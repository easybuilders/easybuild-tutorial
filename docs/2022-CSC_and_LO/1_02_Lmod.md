# The Lmod module system

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

## Lmod hierarchy

### User view

Lmod supports a module hierarchy. In a hierarchy, there is a distinction between the *installed
modules* and the *available modules*. Available modules are those that can be loaded directly 
without first loading any other module, while the installed modules is the complete set of 
modules that one could load one way or another. A typical use case
is a hierarchy to deal with different compilers on a system and different MPI implementations.
After all, it is a common practice to only link libraries and application code compiled with the
same compiler to avoid compatibility problems between compilers (and to be able to use advanced
features such as link time optimization). This is even more important for MPI, as Open MPI and 
MPCIH-derived MPI implementations have incompatible Application Binary Interfaces. This would lead
to a hierarchy with 3 levels:

1.  The ``Core`` level containing the modules for the compilers themselves, e.g., one or more versions
    of the GNU compiler suite and one or more versions of LLVM-based compilers.

    Loading a compiler module would then make the next level available:

2.  The ``Compiler`` level, containing modules for libraries and packages that only rely on the compilers
    but do not use MPI, as well as the MPI modules, e.g., a version of Open MPI and a version of MPICH.

    Loading one of the MPI modules would then make the next level available:

3.  The ``MPI`` level, containing libraries and applications that depend on the compiler used and the MPI
    implementation.

Now assume that we have two compilers in the hierarchy, Compiler_A and Compiler_B. Their modules would reside
at the ``Core`` level. Both copilers provide the same MPI implementation, MPI_C. So there would be two modules
for ``MPI_C`` in two different subdirectories at the ``Compiler`` level. And further assume that we have an
application, Appl_E, compiled with both Compiler_A and Compiler_B and using MPI_C. For that application there would
also be two module files at the ``MPI`` level,  one in a subdirectory corresponding ao Compiler_A and MPI_C and one
in a subdirectory corresponding to Compiler_B and MPI_C. To be able to load the module for Appl_E, a user should
first load Compiler_A, then load MPI_C and only then is it possible to load the module for Appl_E:

```bash
module load Compiler_A MPI_C Appl_E
```

What is interesting is what happens if the user now loads Compiler_B:

```bash
module load Compiler_B
```

In a properly designed and implemented hierarchy, Lmod will unload Compiler_A which will also trigger the unloading/deactivation
of MPI_C and Appl_E. It will then load the module for Compiler_B and proceed with looking if it can find another module for
MPI_C. That will then be loaded which now makes a different module for Appl_E available, which Lmod will proceed to load. If it
cannot find an exact match for the version, Lmod will even try to locate a different version. Hence the situation after loading 
Compiler_B is that now modules are loaded for Compiler_B, MPI_C for Compiler_B and Appl_E for Compiler_A with MPI_C.
All this requires very little effort from the module file programmer and very little logic in the module files. E.g., rather
then implementing a single module file for Appl_E that would require logic to see which compiler and MPI implementation is loaded
and depending on those adapt the path to the binaries, several very simple modules need to be written with very little 
logic, and one could add an Appl_E module for a different compiler or MPI implementation without touching any of the already
existing module files for that application.


### Building blocks

Some mechanisms in Lmod make implementing a hierarchy fairly easy (though there are a lot of hidden pitfalls)

-   The *MODULEPATH* environment variable determines which modules are available. MODULEPATH is different from any other 
    path-style variable in Lmod in that any change will immediately trigger a re-evaluation of which modules are available
    and trigger deactivating modules that are no longer available when a directory is removed from the MODULEPATH or
    looking for alternatives for deactivated modules when a directory is added to the MODULEPATH.

-   The *"one name rule"*: Lmod cannot have two modules loaded with the same name (but a different version). By default, when loading
    a module with the name of an already loaded module, Lmod will automatically swap the old one with the new one, i.e., unload the
    already loaded module and load the new one. 

-   The *family* concept: It is possible to declare a module to be part of a family using a command in the module file. No two modules
    of the same family can be loaded at the same time, and Lmod will again by default auto-swap the already loaded one with the one
    being loaded. The procedure is different though as Lmod now first has to read the new module file to discover the family, and this
    may lead to more side effects. But that discussion is outside the scope of this tutorial.

    The family concept was for a long time a unique feature of Lmod, but it has been added now also to Environment Modules version 5.1.


### Implementation details

The above example could be implemented using 6 module files: One for each compiler, two for the MPI module and 
two for the application module.

```
moduleroot
├── Core
│   ├── Compiler_A
│   │   └── version_A.lua
│   └── Compiler_B
│       └── version_B.lua
├── Compiler
│   ├── Compiler_A
│   │   └── version_A
│   │       └── MPI_C
│   │           └── version_C.lua
│   └── Compiler_B
│       └── version_B
│           └── MPI_C
│               └── version_C.lua
└── MPI
    ├── Compiler_A
    │   └── version_A
    │       └── MPI_C
    │           └── version_C
    │               └── Appl_E
    │                   └── version_E.lua
    └── Compiler_B
        └── version_B
            └── MPI_C
                └── version_C
                    └── Appl_E
                        └── version_E.lua
```

Besides the module functions needed to create the environment needed to run the compiler, the module file for
Compiler_A would need only two lines to implement the hierarchy:

```Lua
family('Compiler')
prepend_path('MODULEPATH', 'moduleroot/Compiler/Compiler_A/version_A')
```

There are now two different ``version_C.lua`` files. One contains the necessary calls to module functions to
initialise the environment to use the version compiled with Compiler_A/version_A while the other contains the
necessary functions to do that for Compiler_B/version_B. Again, two more lines are needed to implement the hierarchy.
E.g., for ``moduleroot/Compiler/Compiler_A/version_A/MPI_C/version_C.lua``: 

```Lua
family('MPI')
prepend_path('MODULEPATH', 'moduleroot/MPI/Compiler_A/version_A/MPI_C/version_C')
```

Finally two vesions of the ``version_E.lua`` file are needed, one to prepare the environment for using the 
package with Compiler_A anmd MPI_C and one for using the package with Compiler_B and MPI_C. However, these
are just regular modules and no additions are needed to work for the hierarchy.

Both EasyBuild and Spack support Lmod hierarchies and with these tools it is also fairly automatic to create
different versions of the module files for each compiler and MPI library used to build the application. When
hand-writing modules it may be more interesting to have a generic module which would work for all those cases
and that is also possible with Lmod. Lmod does have a range of *introspection functions* that a module can use 
to figure out its name, version and place in the module tree. All that would be needed is that the various
instances of the module file are at the correct location in the module tree and link to the generic file which
can be outside the module tree. In fact, this feature is used on LUMI to implement the modules that load a
particular version of the hardware for a particular section of LUMI.

---

## Finding modules

TODO: module spider, module help, module whatis, module keyword and where do they get their information.

---

## Further reading


---

*[[next: The Cray Programming Environment]](1_03_CPE.md)*
