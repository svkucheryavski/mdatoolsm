%% Introduction to mdadata class
%
% Class _mdadata_ extends usability of conventional matrices, 
% allowing to keep row and column names with data values and use them when 
% show or plot the data. The _mdadata_ can be used only with numerical values. 
%
% Every object of _mdadata_ class has following properties, which can be
% set by a user when creating:
%
% * _values_ data values, a matrix with numbers
% * _rowNames_ a cell array with row names (optional)
% * _colNames_ a cell array with column names (optional)
% * _dimNames_ a cell array with names for each of the two dimensions (optional)
% * _name_ a text string with short name of the dataset (optional)
%
% The default syntax for creating the dataset object is:
%
%  data = mdadata(values, objNames, colNames, dimNames, name);
%
% Most of the properties are optional, they will be generated automatically 
% or remain empty if user does not provide the proper values:
%

% Create a dataset with default property values:
d = mdadata([180 85; 172 68; 156 50]);
show(d)

disp('Dim names are:')
disp(d.dimNames)

%%
% Function |show()| shows dataset values as a table with column and row
% names. As one can see column names were generated as |'1'|, |'2'| and
% so on and row names remain empty. Default dimnames values are 
% |'Objects'| and |'Variables'| and dataset name remains empty. The row
% names and column names must be unique!
%
% Here is an example with all options.
%

% create a dataset with all properties provided
d = mdadata([180 85; 172 68; 156 50], {'Lars', 'Peter', 'Lena'}, ...
   {'Height', 'Weight'}, {'People', 'Parameters'}, 'People data');
show(d)

%% 
% Column and row names should consist only of latin letters and numbers. 
% However you can provide them in a free form (e.g. (_'Height of person, cm'_) and 
% the name will be converted as following: spaces will be removed and every word 
% capitalised, if there are punctuation marks or parentheses they will 
% be also removed as well as the part of the name after the first punctuation
% symbol (for the example above it will become _'HeightOfPerson'_). 
% 
% This is needed to identify the names correctly when subset the datasets with
% logical expressions. The original (user provided) names will be also kept and 
% used as labels when you print or plot the data.
%

d = mdadata([180 81; 172 66; 156 48], {'Lars Larsen', 'Peter from room 22', 'Lena'}, ...
   {'Height', 'Body mass (kg)'});

show(d)

disp('Column names are:')
disp(d.colNames)

disp('Row names are:')
disp(d.rowNames)

%%
% If it is needed to specify only selected parameters, the others should
% be provided as empty arrays:

% create a dataset with variable and dimension names provided
d = mdadata([180 85; 172 68; 156 50], [], {'Height', 'Weight'}, {'People', 'Parameters'});
show(d)

%%
% Names and values can be changed for existent object:

d = mdadata([180 85; 172 68; 156 50]);

d(:, 1).colNames =  {'Height'};
d.dimNames = {'People', 'Parameters'};
d(1, :).values = [181 88];

show(d)

%%
% Rows and columns can be removed using specific methods.
%

d = mdadata([180 85 20; 172 68 20; 156 50 21; 161 51 22]);
show(d)

d.removecols(1);
show(d)

d.removerows(2:3);
show(d)

%%
% You already know about function |show()|, it has an additional
% parameter, which defines how many significant digits to show (default value 
% is 3):

d = mdadata([180 0.02345; 175 0.00123]);

show(d)
show(d, 2)
show(d, 5)
