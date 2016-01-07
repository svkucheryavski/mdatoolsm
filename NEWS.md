v.0.1.6
=======
* new behaviour for all statistical methods (`mean()`, `std()`, ...), now values are calculated for each column of a dataset
* manual x-values now can be provided to `gplot()` (similar to `plot()`)
* if a vector with numbers is provided for column names, the numbers will be used as x-values for line plots
* fixed a bug in classification plot which worked incorrectly if reference data is not provided
* other small improvememnts to the plotting methods for `mdadata` objects
* help and GitBook documentation were adjusted according to the changes

v.0.1.5
=======
* `mdaplsda()` can now work with vector of logical values as a second argument
* improvements to classification plot for models and results
* fixed bug in `predict()` method for PLS-DA, which did not work if references have not been provided
* scatter plot for scores now show the explained variance for each component in axis label
* fixed a bug in PCA when cross-validation always used SVD regardless value for Method parameter

v.0.1.4
=======
* new plots for PLS model: `plotxloadings()`, `plotxyloadings()` and `plotweights()`
* small improvements for regression coefficients plot
* methods `scatter()` and `plot()` now have a new parameter `'Groupby'` for easy color grouping
* method `scatter()` has a new parameter `'ShowContour'` for drawing contour for a cluster of points

v.0.1.3
========
* fixed bug in `predict()` method for regression, which did not work if y references have not been provided
* small improvements to the `regcoeffs` class
* small improvements to the `mdamlr` class
* fixed a bug in `decomp`, which lead to an error when `mdaimage` is used as a data source
* NIPALS algorithm is implemented for PCA (`'nipals'`)
* The `mdapca` class got a new method ? `biplot()`

v.0.1.2
========
* fixed bug in SIMCA which did not allow to use `predict()`
* performance plots for classification do not require class number any more
* overview plot for SIMCA and PCA now works correctly if only one component selected
* bar and line plots for performance now works correctly if only one component is selected

v.0.1.1
========
* fixed bug in PLS-DA which did not allow to use `redict()`
* fixed bug with wrong calculation of false positives

v.0.1.0
========
* SIMCA one-class classification is implemented
* Multiplicative Scatter correction added to preprocessing
* any math function (e.g. log, power, etc) can now be added to preprocessing object
* several changes in names of variables and parameters (e.g. Q2 residuals -> Q residuals)
* fixed a bug when changing parameter Alpha in PCA did not change the statistical limits
* JK confidence intervals on regression coefficients plot are shown as lines if line plot is used
* any `ldecomp` object (e.g. PCA or PLS results) has a new property residuals, E = X - TP'
* plots for individual object and variable residuals are available (`plotobjres`, `plotvarres`)
* small bug fixes and optimization
* from this release, the release versions will have more sound structure: x.0.0. for major releases 
(significant changes in code), 0.x.0 for minor releases (new methods or functionality), 
0.0.x for bug fixes and small improvements


v.0.0.16
========
* color grouping works better if number of groups is small (up to 8)

v.0.0.15
========
* fixed compatibility issues with R2015b

v. 0.0.14
=========
* PCA like model can be now obtained ICA algorithm
* new preprocessing methods: "whitening", "norm" and "ref2abs"
* bugs fixes and code improvements
* documentation (HTML) has been moved to GitBook
* old GUI tools were removed, new under developing

v. 0.0.13
=========
* fixed a bug lead to wrong factor levels when concatenate datasets
* small bugs fixes and code improvements

v. 0.0.12
=========
* small improvements and bug fixing 
* factors functionality has been revised and improved in mdadata
* for MLR, PLS and PLS-DA confidence intervals are calculated using Jack-Knife approach.
* for PLS model VIP scores and selectivity ratio are calculated

v 0.0.11
========
* small improvements and bug fixing for factors
* fixed a bug with test set validation in PLS-DA

v 0.0.10
========
* fixed a bug with numeric row names

v 0.0.9
=======
* PLS-DA classification is implemented (`mdaplsda`, `plsdares`)
* fixed several bugs and made small improvements
* fixed bug with wrong calculation of slope in regression results
* fixed issue with wrong position of explorer window on screen
* small changes in color scheme for cross-validation results
* Quick Start guide is finished

v 0.0.8
=======
* fixed several small bugs
* added method `show()` for preprocessing object
* added documentation for preprocessing object and methods


