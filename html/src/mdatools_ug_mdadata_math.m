%% Mathematical operators and functions
%
% The datasets can be transposed and concatenated. If column names or row 
% names in the concatenated datasets are not unique, this will be corrected
% by adding an additional letter to the names:

load people

d = people(1:4, 1:5);

show(d')
show([d d])
show([d; d])

%%
% The _mdadata_ objects supports most of the basic arithmetic operations as
% well as some fuctions directly, converting all names automatically:
%

a = mdadata(reshape(1:15, 5, 3));
b = mdadata(reshape(15:-1:1, 5, 3));

show(a + b)
show(a - b)
show(a * 5)
show(a * b')
show(a .* b)
show(a ./ b)

%% 
% Linear equations can be solved directly for _mdadata_ objects.

load people

X = people(:, {'Weight', 'Beer', 'Swim'});
y = people(:, 'Height');

b = X\y;
show(b)
show(X * b)

%%
%
% The full list of the functions include: |plus()|, |minus()|, |uminus()|, 
% |times()|, |mtimes()|, |rdivide()|, |mrdivide()|, |ldivide()|, |mldivide()|,
% |round()|, |abs()|, |power()|, |sqrt()|, |log()|, and |exp()|.
%

a = mdadata(reshape(1:15, 5, 3));
show(log(a))
show(exp(a))
show(power(a, 0.5))
show(round(a/2)) 

%%
% Please, be aware that if a calculation results in a complex number, 
% it will be converted to real and method will show a warning:

d = mdadata([-1 0.5; 1 0]);
show(log(d))
show(sqrt(d))

%%
% As an extra example we will calculate an BMI (Body Mass Index) of the persons
% in our People data and add it as an extra column to the original dataset.
% As one can see all names remain correct after the calculations.
%
load people

bmi = people(:, 'Weight') ./ (people(:, 'Height') / 100).^2;
bmi.colNames = {'BMI'};
newdata = [people bmi];

show(bmi(1:5));
show(newdata(1:5, :));

%%
% Calculation of size and length can be done using the same way as with matrices,
% plus there are two properties |nrow| and |ncol|. Function |numel()| was not 
% overrided due to some technical reasons, so it will return 1 instead of 
% number of values (use |numel(d.values)| if needed):
%

disp(people.nRows)
disp(people.nCols)
disp(size(people))
disp(length(people))
disp(numel(people))
