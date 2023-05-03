# Part III: Advanced topics

*[[back to start page]](index.md)*

In this section we mostly cover "good to know that they exist" features as they are not used
on LUMI, or not really accessible to regular user installations that are performed with the
LUMI ``EasyBuild-user`` module. Hooks are used on LUMI, but it is not really advised to
overwrite the centrally defined hooks with a local file. And the whole structure of the 
EasyBuild integration is also set up to make use of the GitHub integration in the future.

* [Using EasyBuild as a library](3_01_easybuild_library.md)
* [Using hooks to customise EasyBuild](3_02_hooks.md)
* [Submitting installations as Slurm jobs](3_03_slurm_jobs.md)
* [Module naming schemes (incl. hierarchical)](3_04_module_naming_schemes.md)
* [GitHub integration to facilitate contributing to EasyBuild](3_05_github_integration.md)
