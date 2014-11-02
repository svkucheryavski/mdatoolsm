clear
clc

disp('1. Create simple object.')

echo on
d = mdadata([180 85; 172 68; 156 50]);
show(d)
echo off

disp('Dim names are:')
disp(d.dimNames)

disp('2. Create object with all names.')

echo on
d = mdadata([180 85; 172 68; 156 50], {'Lars', 'Peter', 'Lena'}, ...
   {'Height', 'Weight'}, {'People', 'Parameters'}, 'People data');
echo off

show(d)

disp('3. Create object with full names.')

echo on
d = mdadata([180 81; 172 66; 156 48], {'Lars Larsen', 'Peter from room 22', 'Lena'}, ...
   {'Height', 'Body mass (kg)'});
echo off

show(d)

disp('Column names are:')
disp(d.colNames)

disp('Row names are:')
disp(d.rowNames)

disp('4. Create object with dimension names.')

% create a dataset with variable and dimension names provided
echo on
d = mdadata([180 85; 172 68; 156 50], [], {'Height', 'Weight'}, {'People', 'Parameters'});
echo off
show(d)

disp('5. Change names for an object.')

echo on
d = mdadata([180 85; 172 68; 156 50]);

d(:, 1).colNames =  {'Height'};
d.dimNames = {'People', 'Parameters'};
d(1, :).values = [181 88];
echo off

show(d)

disp('6. Remove columns and rows.')

echo on
d = mdadata([180 85 20; 172 68 20; 156 50 21; 161 51 22]);
echo off
show(d)

echo on
d.removecols(1);
echo off
show(d)

echo on
d.removerows(2:3);
echo off
show(d)

disp('7. Show object values with various sigfig.')

echo on
d = mdadata([180 0.02345; 175 0.00123]);

show(d)
show(d, 2)
show(d, 5)
echo off
