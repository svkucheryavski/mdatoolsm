%% Getting started with mdadata
%
% By default MATLAB does not provide a possibility to use names for rows
% and columns (or other dimensions if we are talking about arrays), which
% leads to a lot of extra code even for some simple actions, e.g. showing
% a scatter plot with proper axis labels. There are several toolboxes, which
% tackle the problem by using a specific class for datasets. The _mdadata_  
% class was created for these purposes.
%
% The _mdadata_ is quite simple in use and it has many arithmetic, 
% mathematic and statistic methods overridden so one can e.g. multiply 
% datasets or calculate datasets statistics for their columns directly,
% without extracting the dataset values. Besides that the _mdadata_ class overrides 
% standard plotting
% functions, allowing to create annotated plots easily as well as some GUI
% plotting tools to make interactive plots. 
%
