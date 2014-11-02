clc
clear
disp('1. Contcatenation and transposition')

echo on
load people

d = people(1:4, 1:5);

show(d')
show([d d])
show([d; d])
echo off

disp('2. Arithmetics')

echo on
a = mdadata(reshape(1:15, 5, 3));
b = mdadata(reshape(15:-1:1, 5, 3));

show(a + b)
show(a - b)
show(a * 5)
show(a * b')
show(a .* b)
show(a ./ b)
echo off

disp('3. Linear regression')

echo on
load people

X = people(:, {'Weight', 'Beer', 'Swim'});
y = people(:, 'Height');

b = X\y;
show(b)
show(X * b)
echo off

disp('4. Functions')
echo on
a = mdadata(reshape(1:15, 5, 3));
show(log(a))
show(exp(a))
show(power(a, 0.5))
show(round(a/2)) 
echo off

disp('5. Not real data handling')
echo on
d = mdadata([-1 0.5; 1 0]);
show(log(d))
show(sqrt(d))
echo off

disp('6. BMI example')
echo on
load people

bmi = people(:, 'Weight') ./ (people(:, 'Height') / 100).^2;
bmi.colNames = {'BMI'};
newdata = [people bmi];

show(bmi(1:5));
show(newdata(1:5, :));
echo off

disp('7. Sizes and length')
disp(people.nRows)
disp(people.nCols)
disp(size(people))
disp(size(people, 1))
disp(size(people, 2))
disp(length(people))
disp(numel(people))
