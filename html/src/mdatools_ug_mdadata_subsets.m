%% Sorting data and making subsets 
%
%%
% In this section and onwards we will use a _People_ dataset instead of
% generating numbers. The dataset consists of measurements of 12 variables 
% done for 32 persons (16 males and 16 females, half from Scandinavia, half
% from Mediterranian region). The variables include height, weight,
% shoesize, income, beer and wine consumption and so on. For details,
% please, see _K. Esbensen. Multivariate data analysis in practice. Camo,
% 2005_.
%
% The data can be sorted using one or several columns:

load people

show(people)

people.sort('Sex')
show(people)

people.sort({'Sex', 'Region'}, 'descend')
show(people)

%%
% Making subsets is as easy as with matrices, just specify indices for rows
% and columns:
%

load people

show(people([1, 2], :))
show(people(1:3, 1:2:end-2))

%%
% In addition to that, _mdadata_ objects can be also subset by using column and row
% names, either one or several, combined to a cell array.
%

show(people(1:5, 'Height'))
show(people('Lars', :))
show(people({'Lars', 'Lene'}, {'Height', 'Weight'}))

%%
% Names can also be used to specify a sequence of columns or rows:
%

show(people(1:3, 'Height:Income'))
show(people('Lars:Lene', :))
show(people('Lars:Lene', 'Height:Income'))

%%
% Be sure that you use correct column names, not the ones that were
% specified for printing or plotting. Check |data.colNames| if you have
% doubts.

d = mdadata([180 85; 165 55], {}, {'Height (cm)', 'Body mass (kg)'});

disp('Column names are:')
disp(d.colNames);

% correct name
show(d(:, 'Bodymass'))

% wrong name
try
   show(d(:, 'Body mass (kg)'))
catch e
   disp(e.message)
end   

%%
% Last but not least, one can use logical expressions with columns to make 
% subsets. In this case the logical expression must be written as a text
% string and be used instead of row indices. In the expression you can use 
% column names or numbers, in the latter case they should be specified
% with leading dollar sign: |'$1'|, |'$15'| and so on. Here are some
% examples:
%

show(people('Sex == 1', 1:4));
show(people('Sex == 1 & Weight > 60', 1:4));
show(people('$1 < 180 & $3 == -1', 1:4));

%% 
% function |find()| can be used to get indices of rows, which meet logical
% conditions.
%

i = find(people, 'Sex == 1 & Region == -1');
disp(people.rowNames(i)');


