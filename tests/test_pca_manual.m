%% NIPALS

clear
clc

load('people')

m1 = mdapca(people, 'Scale', 'on', 'CV', {'full'});
m2 = mdapca(people, 'Scale', 'on', 'CV', {'full'}, 'Method', 'nipals');
m3 = mdapca(people, 5, 'Scale', 'on', 'CV', {'full'});
m4 = mdapca(people, 5, 'Scale', 'on', 'CV', {'full'}, 'Method', 'nipals');

summary(m1)
summary(m2)
summary(m3)
summary(m4)

figure
plot(m1)

figure
plot(m2)

figure
plot(m3)

figure
plot(m4)

%% Biplot

clear
clc
load('people')

m = mdapca(people, 'Scale', 'on');

figure
subplot 221
biplot(m)
subplot 222
biplot(m, 1:2, 'Labels', 'names', 'Marker', 's')
subplot 223
biplot(m, 1:2, 'Labels', 'names', 'ScoresColor', 'b', 'LoadingsColor', 'r')
subplot 224
biplot(m, 1:2, 'Labels', 'numbers', 'ScoresTextColor', 'c', 'LoadingsTextColor', 'm')



