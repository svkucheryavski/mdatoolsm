clear all
clc

d = [10 30 -10 15; 21 23 22 25; 11 23 34 15; 11 21 31 45; 34 56 34 25; 12 34 31 45; 33 22 -10 15; 16 17 22 25];

i1 = [1 4 3 6 7];
i2 = [2 3 5 8];

dd = mdadata(d);
dd.factor(3, {'A', 'B', 'C', 'D'});
dd.factor(4, {'X', 'Y', 'Z'});

dd1 = dd(i1, :);
dd2 = dd(i2, :);

disp('Original matrix:')
disp(d)

disp('Dataset:')
show(dd)

disp('Subset 1:')
show(dd1)
disp(dd1.values)

disp('Subset 2:')
show(dd2)
disp(dd2.values)

disp('Sort default:')
dd.sort(3)
show(dd)
disp(dd.values)

disp('Sort descend:')
dd.sort(3, 'descend')
show(dd)
disp(dd.values)

disp('Vertcat:')
dda = [dd1; dd2];
disp(dda.values)
show(dda)

%%
disp('Split factor:')
show(dda.splitfactor(3))

disp('Grouping data:')
show(dda)
show(dda.getgroups([3 4]))

%% 
figure
subplot(1, 2, 1)
gscatter(dda(:, 1:2), dda(:, 3:4));
subplot(1, 2, 2)
gplot(dda(:, 1:2), dda(:, 3:4));


%%

show(mean(dda, dda(:, 3:4)))
show(median(dda, dda(:, 3:4)))
show(min(dda, dda(:, 3:4)))
show(max(dda, dda(:, 3:4)))
show(sum(dda, dda(:, 3:4)))

show(percentile(dda, dda(:, 3:4), 25))
show(percentile(dda, dda(:, 3:4), 10:10:90))

show(var(dda, dda(:, 3:4)))
show(std(dda, dda(:, 3:4)))
show(se(dda, dda(:, 3:4)))

show(ci(dda, dda(:, 3:4)))
show(ttest(dda, dda(:, 3:4)))


%% the same for people data

load 'people'
people.factor('Sex', {'M', 'F'});
people.factor('Region', {'A', 'B'});

show(mean(people, people(:, {'Sex', 'Region'})))
show(median(people, people(:, {'Sex', 'Region'})))
show(min(people, people(:, {'Sex', 'Region'})))
show(max(people, people(:, {'Sex', 'Region'})))
show(sum(people, people(:, {'Sex', 'Region'})))

show(percentile(people, people(:, {'Sex', 'Region'}), 25))
show(percentile(people, people(:, {'Sex', 'Region'}), 25:25:99))

show(var(people, people(:, {'Sex', 'Region'})))
show(std(people, people(:, {'Sex', 'Region'})))
show(se(people, people(:, {'Sex', 'Region'})))

show(ci(people, people(:, {'Sex', 'Region'})))
show(ci(people, people(:, {'Sex', 'Region'}), 0.01))

show(ttest(people, people(:, {'Sex', 'Region'})))
show(ttest(people(:, 'Height'), people(:, {'Sex', 'Region'}), 175))

%% plots


people.excludecols({'Income', 'Beer'});
people.excluderows([1 5 10]);

figure
subplot 221
gscatter(people, people(:, {'Sex', 'Region'}), 'Labels', 'names');
subplot 222
scatter(people, 'Groupby', people(:, {'Sex', 'Region'}), 'ShowContour', 'on');
subplot 223
gplot(people, people(:, {'Sex', 'Region'}));
subplot 224
plot(people, 'Groupby', people(:, {'Sex', 'Region'}));

figure
subplot 221
gscatter(people, people(:, {'Sex', 'Region'}), 'Labels', 'names', 'ShowExcluded', 'on');
subplot 222
scatter(people, 'Groupby', people(:, {'Sex', 'Region'}), 'ShowContour', 'on', 'ShowExcluded', 'on');
subplot 223
gplot(people, people(:, {'Sex', 'Region'}), 'ShowExcluded', 'on');
subplot 224
plot(people, 'Groupby', people(:, {'Sex', 'Region'}), 'ShowExcluded', 'on');


