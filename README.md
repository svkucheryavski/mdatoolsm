# Multivariate Data Analysis toolbox for MATLAB

## Description ##

_mdatools_ is a free open source toolbox for analysis of multivariate
experimental data based on methods widespread in [Chemometrics](http://en.wikipedia.org/wiki/Chemometrics).
The toolbox can work with conventional two-way datasets (where rows are objects or measurements and
columns are variables) as well as with colour and hyperspectral images. It has both command line
and GUI tools allowing to explore models and datasets interactively. The project is currently under
developing and e.g. GUI is in alpha version and has limited functionality, however most of the
command line methods work well in the current version.

It is recommended to start learning the toolbox with a guide, which gives 
a brief overview of basic methods with a lot of examples (`web mdatools_quick.html`).
It allows you to start working with the toolbox after 30 minutes 
learning. Then just continue with User guide (`web mdatools.html`) to get acquainted with all 
available features and details.

The toolbox was tested using MATLAB 2012b and 2014b and should also work on
versions in between. For the basic functionality you do not need any additional toolboxes
installed, however for GUI tools Image Processing toolbox is needed (this will be fixed in future
releases). All methods were tested using well-known datasets, but there still could be some bugs,
in this case please report to <svkucheryavski@gmail.com>.


## Installation ##

The current version is _0.0.11_ (from 13.11.2014). Next version is going to be published in late
November and will include mostly bug fixings and small improvements for the code as well as
more methods.

Installation is easy and the procedure is similar to most of the others 3rd party MATLAB Toolboxes.
Download zip archive for the latest release and unzip it to the folder you use to keep you MATLAB code,
for example to _Documents/MATLAB_ or _Documents/MATLAB/Toolboxes_. Open the folder in MATLAB
environment and run `install.m` script, which will do the rest.

If you upgrade from previous version, run `uninstall` on the old version first, then remove old
folder, unzip the new version and follow the instructions above.

## Bug reports and suggestions ##

If you find a bug, please, send a message to [svkucheryavski@gmail.com](mailto:svkucheryavski@gmail.com)
with detailed description or use a form on GitHub. Any comments and suggestions will also be
highly appreciated.
