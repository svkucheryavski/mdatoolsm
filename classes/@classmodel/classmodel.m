classdef classmodel < handle
   methods
   end
   
   methods(Static = true)
      
      function c = convertClasses(c, className)         
         if isa(c, 'mdadata')
            return
         elseif islogical(c)
            c = mdadata(c);         
            if sum(c.valuesAll) == c.nRowsAll
               c.factor(1, {className});
            else
               c.factor(1, {'None', className});
            end
         end   
      end   
      
      function newc = getClassFromFactor(c, className)
         if isa(c, 'mdadata')
            if c.nCols ~= 1 || ~isfactor(c, 1)
               error('Class variable should be a dataset with one factor column!')
            end   
            
            factorLevelNames = c.factorLevelNames{1};
            factorLevels = unique(c.valuesAll);

            if ischar(className)
               ind = ismember(factorLevelNames, className);
               if ~any(ind)
                  error('Wrong class name!')
               end

            elseif isnumeric(className)
               ind = className;
               if ind < 1 || ind > numel(factorLevels)
                  error('Wrong value for class number!');
               end
               className = factorLevelNames{ind};    
            else
               error('Specify class name or number!')
            end   

            newc = c.valuesAll == factorLevels(ind);
            newc = mdadata(newc, c.rowNamesAll, c.colNames, c.dimNames, c.name);
            newc.rowFullNames = c.rowFullNamesAll;
            newc.colFullNames = c.colFullNames;
            if sum(newc.valuesAll) == c.nRowsAll
               newc.factor(1, {className});
            else
               newc.factor(1, {'None', className});
            end
            newc.excluderows(c.excludedRows);
         else
            newc = mdadata(c, {}, {className});
            if sum(newc) == size(c, 1)
               newc.factor(1, {className});
            else
               newc.factor(1, {'None', className});
            end
         end   
         
         
      end   
   end   
end

