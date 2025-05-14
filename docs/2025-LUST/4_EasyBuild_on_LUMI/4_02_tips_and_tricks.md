# Tips & tricks

## Long lists of elements for `preconfigopts` or options for `configopts`.

An example showing both is in recent [LUMI NAMD EasyConfigs](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib/tree/main/easybuild/easyconfigs/n/NAMD), e.g., 
["NAMD-3.0-cpeGNU-24.03-rocm-gpu-resident.eb"](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib/blob/main/easybuild/easyconfigs/n/NAMD/NAMD-3.0-cpeGNU-24.03-rocm-gpu-resident.eb).

-   [Line 100](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib/blob/main/easybuild/easyconfigs/n/NAMD/NAMD-3.0-cpeGNU-24.03-rocm-gpu-resident.eb#L100) shows `preconfigopts` 

    The example is not ideal as it would have been better to join with `&&` also to guarantee
    that the whole configure command fails if one of the commands in `preconfigopts` failed.

-   [Line 106](https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib/blob/main/easybuild/easyconfigs/n/NAMD/NAMD-3.0-cpeGNU-24.03-rocm-gpu-resident.eb#L106)
    shows the `configopts`.

Of course, one could try to create one large string in Python, or break the assignment up, e.g.,

```
configopts  = '--charm-arch $EBTYPECHARMPLUSPLUS '
configopts += '--charm-base $EBROOTCHARMPLUSPLUS '
...
```

(and note the spaces that we now have to add at the end), but the "join" method has something
elegant, makes it very easy to add additional flags or commands, and is less error-prone.
There is also plenty of space left on each line to explain why an option is used or what it
means, to make the job easier for others who may want to update or customise this EasyConfig.


## More to follow....


*[[Next: Additional reading]](../5_00_additional_reading.md)*

