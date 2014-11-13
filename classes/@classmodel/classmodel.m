classdef classmodel < handle
      
   methods(Static = true)
      function newc = getClassFromFactor(c, className)
         factorLevelNames = c.factorLevelNames{1};
         factorLevels = unique(c.valuesAll, 'stable');
                  
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
         newc.factor(1, {'None', className});
         newc.excluderows(c.excludedRows);
      end   
   end   
end

