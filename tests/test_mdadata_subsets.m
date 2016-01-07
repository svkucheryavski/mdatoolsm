clear
clc

disp('1. Sorting data')

echo on
load people

show(people)

people.sort('Sex')
show(people)

people.sort({'Sex', 'Region'}, 'descend')
show(people)
echo off

disp('2. Simple subsets')

echo on
load people

show(people([1, 2], :))
show(people(1:3, 1:2:end-2))
echo off

disp('3. Subsets with names')

echo on
show(people(1:5, 'Height'))
show(people('Lars', :))
show(people({'Lars', 'Lene'}, {'Height', 'Weight'}))
echo off

disp('4. Subsets with sequences of names')

echo on
show(people(1:3, 'Height:Income'))
show(people('Lars:Lene', :))
show(people('Lars:Lene', 'Height:Income'))
echo off

disp('5. Check for name errors')

echo on

d = mdadata([180 85; 165 55], {}, {'Height (cm)', 'Body mass (kg)'});

disp('Column names are:')
disp(d.colNames);

% correct name
show(d(:, 'Bodymasskg'))

% wrong name
try
   show(d(:, 'Body mass (kg)'))
catch e
   disp(e.message)
end   
echo off

disp('6. Subsets with logical expressions')

echo on

show(people('Sex == 1', 1:4));
show(people('Sex == 1 & Weight > 60', 1:4));
show(people('$1 < 180 & $3 == -1', 1:4));

echo off

disp('7. Using find()')

echo on

i = find(people, 'Sex == 1 & Region == -1');
i
disp(people.rowNames(i)');

echo off
