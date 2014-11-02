%% Hiding rows and columns
%
% Rows and columns in the |mdadata| datasets can be excluded from
% calculations and other manipulations. The main idea is to give a tool
% which allows to exclude/hide part without actually removing it. It can be 
% used, for possible outliers. Here we will show several examples on 
% how this hiding works.
%
% To exclude row or column can be done with methods |excluderows()| and
% |excludecols()| correspondingly. Number, sequence, names or sequence of
% names can be used as an argument.
%

load people
show(people(1:5, :))

people.excludecols({'Income', 'Beer', 'IQ'})
show(people(1:5, :))

people.excluderows(1)
show(people(1:5, :))

%%
% The excluded data is absolutly hidden for most of the operations, including
% mathematical calculations and plots.
%

m = mean(people);
show(m)

%%
% One can print the names and numbers of excluded rows and columns. If
% several excluded rows or columns are successive, they will be shown as a
% sequence.
%

people.showexcludedcols()
people.showexcludedrows()

%%
% The excluded values can be unhide as easily as hide.

people.includecols('IQ')
people.includerows(1)

show(people(1:5, :))