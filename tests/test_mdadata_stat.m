clear
clc

disp('1. Simple statistics')

echo on

load people
data = people(:, [1:2 4:6]);

show(mean(data))
show(std(data))

show([mean(data); std(data); var(data); min(data); max(data)])

echo off

disp('2. Covariance and correlation')

echo on
show(cov(data))
show(corr(data(:, [1 3])))
echo off

disp('3. Percentile and CI')

echo on
show(percentile(data, 5))
show(se(data))
show(ci(data))
show(ci(data, 0.01))
echo off

disp('4. One sample t-test')

echo on
show(ttest(data))
show(ttest(data(:, 'Height'), 170))

show(summary(data))
echo off

