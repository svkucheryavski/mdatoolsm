%% Factors and groups
%
% Dataset class has a posibility to mark one or several columns as factors.
% Factor is a qualitative variable, it has fixed values (levels) and
% normally can not be treated as quantitative variable.
%
% Factors can be used for splitting datasets, combine data values into groups,
% calculate statistics and show plots for the groups. Besides that, one can calculate 
% qualitative statistics for factors, such as frequencies, contingency table,
% chi-square test for association and so on. All mathematic operators and
% functions as well as methods for quantitative statistic will ignore
% factors in calculations.
%
% To add a factor you need to have a column in the dataset with discrete numeric
% values, such as variables _Sex_ and _Region_ in the _People_ data. It is
% possible to define text values for each of the levels. Keep level names
% as simple as possible and avoid using spaces and other special symbols.
% The column name for a factor is marked with an asterisk when dataset is 
% displaying.
%

   load people
   
   d = people(1:8, :);
   show(d)
   
   % mark 'Sex' as a factor
   d.factor('Sex');
   show(d)
   
   % mark two columns as factors with text levels
   d.factor('Sex', {'Male', 'Female'})
   d.factor('Hairleng', {'Short', 'Long'})
   show(d)

%% 
% As you can see below _Sex_ and _Hairleng_ are now ignored in calculations.
% You can also convert a factor back to a quantitative variable by using
% method |notfactor()|.
%
   show(mean(d))
   show(d * 10)
   
   % unmark 'Sex' to make it normal variable
   d.notfactor('Sex');
   
   % now 'Sex' is used for calculations again
   show(d)
   show(mean(d))

%%
% Factors can be used to goup your data according to combinations of factor
% levels. Method |getgroups()| makes a dataset with binary values (0, 1)
% for each of the possible combinations of selected factors. Even though
% theres is no need to use this method directly, it gives a good idea how
% the splitting is made.
% 

d = people(1:10, :);
d.factor('Sex', {'Male', 'Female'})
d.factor('Hairleng', {'Short', 'Long'})

show(d.getgroups({'Sex', 'Hairleng'}))

%%
% The |getgroups()| is widely
% used in statistic and graphical methods. Here we will show how to use
% groups for calculation of quantitative statistics and in the next section graphical
% methods will be discussed.
%
% The idea is rather simple, if one provide a dataset with one or several factors
% as a second argument of any statistical method, the statistics will be
% calculated for first column of original data and the values
% from this column will be split into the groups according to combination of 
% the factor levels. Here is an example:
%

clc

people.factor('Sex', {'Male', 'Female'});
people.factor('Region', {'A', 'B'});
d = people(8:20, :);
show(d)

% just a normal use of mean for a column
m = mean(d(:, 'Height'));
show(m)

% grouping factors are provided
m = mean(d(:, 'Height'), d(:, {'Sex'}));
show(m)

%%
% If a method requires additional parameters, they should be specified after
% dataset with factors.

p = percentile(d(:, 'Height'), 25);
show(p)

p = percentile(d(:, 'Height'), d(:, 'Sex'), 25);
show(p)

%%
% Several factors can be used at the same time.

s = ci(d(:, 'Height'), d(:, {'Sex', 'Region'}));
show(s)

s = ci(d(:, 'Height'), d(:, {'Sex', 'Region'}), 0.10);
show(s)

%% Qualitative statistics
%
% Factors can be also used for calculation of qualitative statistics,
% including frequencies and relative frequencies (proportions) of factor levels,
% confidence interval for proportions, contingency tables for combination
% of two factors, chi square test for association of two factors,
% standardized residuals for observed and expected frequencies.
%
% Let's take a part people data, so number of males and females, 
% is different.
%

load people
data = people(6:20, {'Sex', 'Region'});
data.factor('Sex', {'Male', 'Female'})
data.factor('Region', {'A', 'B'})

%%
% Here how to calculate frequency table, which includes the observed frequencies 
% for each level, relative frequencies (proportions), and confidence interval
% for the proportions. Optional second argument is significance level
% (alpha) for the interval.

f = freq(data(:, 'Sex'));
show(f)

f = freq(data(:, 'Sex'), 0.1);
show(f)

%%
% For investigation of association between two factors one can calculate
% the contingency table.

ct = crosstable(data);
show(ct)

%%
% And use chi-square test for association and standardized residuals.

ch = chi2test(data);
show(ch)

res = crossresid(data);
show(res)

