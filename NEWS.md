# adoptr 0.2.0

* new feature: composite scores allows more generic expressions than just 
    affine score combinations, cf. composite()
* affine scores (s1 + 2*s2) are no longer supported, use composite instead
* more consistent class system: conditional scores no longer need a specification
    of distributions by default (no need for conditional sampel size e.g.).
    Instead, expected() now requires explicit specification of the data and
    prior distribution to integrate with.
* Vignettes updated
* fixed broked tests due to updated rpact



# adoptr 0.1.1

* extended Description field in DESCRIPTION to full paragraph
* provided examples for all user facing functions
* revision of docs



# adoptr 0.1.0

* initial release
