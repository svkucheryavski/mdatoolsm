clear
clc

load('people')

people.factor('Sex', {'Male', 'Female'});
people.factor('Region', {'A', 'B'});

%% Group by for scatter plot

figure
subplot 321
scatter(people, 'Groupby', people(:, 'Sex'))
subplot 322
scatter(people, 'Groupby', people(:, {'Sex', 'Region'}))
subplot 323
scatter(people, 'ShowContour', 'on')
subplot 324
scatter(people, 'Groupby', people(:, 'Sex'), 'ShowContour', 'on')
subplot 325
scatter(people, 'Groupby', people(:, {'Sex', 'Region'}), 'ShowContour', 'on', 'Color', 'rgbc', ...
   'Marker', 'sodx')


mx = [15 50];
my = [15 20];
sx = [5 10];
sy = [4 8];
n = 1900;

x1 = randn(n, 1) * sx(1) + mx(1);
y1 = randn(n, 1) * sy(1) + my(1);
x2 = randn(n, 1) * sx(2) + mx(2);
y2 = randn(n, 1) * sy(2) + my(2);

d = mdadata([ [x1; x2] [y1; y2] ]);
f = mdadata([ zeros(n, 1); ones(n, 1)]);
f.factor(1, {'D1', 'D2'});

subplot 326
scatter(d, 'Groupby', f, 'ShowContour', 'on', 'Color', 'rg', 'Marker', 'sd')


%% Groupby for line plot

clear
clc

load('simdata')

f = mdadata([zeros(100, 1); ones(50, 1)]);
f.factor(1, {'cal', 'test'});

figure
subplot 211
plot(spectra, 'Groupby', f);
subplot 212
plot(spectra, 'Groupby', f, 'Color', 'rg', 'LineStyle', {'--', ':'});


