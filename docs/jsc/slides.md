---?image=docs/img/jsc.jpg&position=right&size=15% auto

### Jülich Supercomputing Centre
@ul
* JSC is a German supercomputing centre since 1987
  - About 200 experts for all aspects of supercomputing and simulation sciences
<br>
* 3 primary systems at the moment
  - JUWELS - modular supercomputing architecture, will reach 70 petaflops in 2020
  - JURECA - CPU, GPU and KNL. To be replaced by successor in 2020
  - JUWELS - AMD, V100 GPU. Geared towards interactive workflows and community services
@ulend
  
---?image=docs/img/jsc.jpg&position=right&size=15% auto

### EasyBuild at JSC

@ul
* Geared toward *normal* user experience
  - Hide lots of indirect software
  - Hierarchy
  - Renaming some modules, lmod tweaks
<br>
* Custom mns, toolchains, easyconfigs, easyblocks
  - Maintenance and contribution issue
  - Working hard to remove this where possible
@ulend

---?image=docs/img/jsc.jpg&position=right&size=15% auto

### Leveraging hooks for user support

@ul
* Very powerful alternative to customisations
  - Much more automated and flexible
  - Easier to maintain
<br>
* Enable user space installations
  - *Guide* people on how to do this properly
@ulend

---?image=docs/img/jsc.jpg&position=right&size=15% auto

### Upgrading and retiring software

@ul
* Provide latest software to new projects by default
  - ***stages*** concept
  - Updates twice per year
  - Encourages users to adopt latest dependencies (performance, bug fixes,...)
<br>
* Give indirect access to "retired" software
@ulend