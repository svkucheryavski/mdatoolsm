# Multivariate Data Analysis toolbox for MATLAB

## Description ##

_mdatools_ is a free open source toolbox for analysis of multivariate
experimental data based on methods widespread in [Chemometrics](http://en.wikipedia.org/wiki/Chemometrics).
The toolbox can work with conventional two-way datasets (where rows are objects or measurements and
columns are variables) as well as with colour and hyperspectral images. Currently only command line
tools are available, old GUI version has been removed from the project and new is now under developing.

All documentation is [available](https://www.gitbook.com/book/svkucheryavski/mdatoolsm/details) at GitBook. 
It is recommended to start learning the toolbox with a 
quick start guide, which gives a brief overview of basic methods with a lot of examples.
It allows you to start working with the toolbox after 30 minutes learning. Then just continue with 
the user guide to get acquainted with all available features and details.

The toolbox was tested using MATLAB 2012b and 2015b and should also work on
versions in between. For the basic functionality you do not need any additional toolboxes
installed. All methods were tested using well-known datasets, but there still could be some bugs,
in this case please report to <svkucheryavski@gmail.com>.


## Installation ##

The current version is _0.1.3_ (from 19.11.2015). 

Installation is easy and the procedure is similar to most of the others 3rd party MATLAB Toolboxes.
Download zip archive for the latest release and unzip it to the folder you use to keep you MATLAB code,
for example to _Documents/MATLAB_ or _Documents/MATLAB/Toolboxes_. Open the folder in MATLAB
environment and run `install.m` script, which will do the rest.

If you upgrade from previous version, run `uninstall` on the old version first (it will clear the path
list and remove folder with toolbox), then unzip the new version and follow the instructions above.

## Bug reports and suggestions ##

If you find a bug, please, send a message to [svkucheryavski@gmail.com](mailto:svkucheryavski@gmail.com)
with detailed description or use a form on GitHub. Any comments and suggestions will also be
highly appreciated.
