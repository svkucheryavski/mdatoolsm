%% Quantitative statistics
%
% Most of the statistical functions can be also applied directly to the _mdadata_ 
% objects. Besides that, a few of additional methods have been implemented, including 
% for example, |summary()| which is an analogue of the same function in R.
% The defaiult functions include: |mean()|, |std()|, |min()|, |max()|,
% |var()|, |cov()|�and |corr()|. 
%
% The functions calculate statistics for each column. The result of calculations 
% is also an object of _dataset_ class.
%
load people

% take only first six columns
data = people(:, [1:2 4:6]);

% calculate simple statistics and show result
show(mean(data))
show(std(data))

% the results of calculation can be concatenated into a single dataset
show([mean(data); std(data); var(data); min(data); max(data)])

%% 
% Calculation of covariance and correlation always results in a matrix.
%

show(cov(data))
show(corr(data(:, [1 3])))

%%
% The additional methods include calculation of percentiles, standard error, 
% confidence intervals, one-sample t-test and summary statistics for a dataset.

show(percentile(data, 5))
show(se(data))
show(ci(data))
show(ci(data, 0.01))

%%
%

show(ttest(data))
show(ttest(data(:, 'Height'), 170))

show(summary(data))

