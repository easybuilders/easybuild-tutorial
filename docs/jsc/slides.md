---?image=docs/img/jsc.jpg&position=right&size=15% auto

# Jülich Supercomputing Centre
@ul[list-spaced-bullets](false)
* JSC is a German supercomputing centre since 1987
  @ul[text-gray]
  * About 200 experts and contacts for all aspects of supercomputing and simulation
    sciences
  @ulend
* 3 primary systems at the moment
  @ul[text-gray]
  * JUWELS - modular supercomputing architecture, will reach 70 petaflops in 2020
  * JURECA - CPU, GPU and KNL. To be replaced by successor in 2020
  * JUWELS - AMD, V100 GPU. Geared towards interactive workflows and community services
  @ulend
@ulend
  
---?image=docs/img/jsc.jpg&position=right&size=15% auto

## EasyBuild at JSC

@ul[list-spaced-bullets](false)
* Geared toward *normal* user experience
  @ul[text-gray]
  * Hide lots of indirect software
  * Hierarchy
  * Renaming some modules, lmod tweaks
  @ulend

* Custom mns, toolchains, easyconfigs, easyblocks
  @ul[text-gray]
  * Maintenance and contribution issue
  * Working hard to remove this where possible
  @ulend
@ulend

---?image=docs/img/jsc.jpg&position=right&size=15% auto

## Leveraging hooks for user support

@ul[list-spaced-bullets](false)
* Very powerful alternative to customisations
  @ul[text-gray]
  * Much more automated and flexible
  * Easier to maintain
  @ulend
  
* Enable user space installations
  @ul[text-gray]
  * *Guide* people on how to do this properly
  @ulend
@ulend

---?image=docs/img/jsc.jpg&position=right&size=15% auto

## Upgrading and retiring software

@ul[list-spaced-bullets](false)
* Provide latest software to new projects by default
  * ***stages*** concept
    * Updates twice per year
  * Encourages users to adopt latest dependencies
    * Performance, bug fixes,...
* Give indirect access to "retired" software
@ulend