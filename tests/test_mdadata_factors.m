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
show(mean(dda(:, 1), dda(:, 3:4)))