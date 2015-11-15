classdef prepItem < handle
   
   properties (SetAccess = 'protected', Hidden = true)
      options = {}
      values
      optionList = {}
      gui
   end
   
   properties (Dependent = true)
      nOptions
   end
   
   methods
      function obj = prepItem(varargin)
      end   
      
      function out = get.nOptions(obj)
         out = size(obj.optionList, 1);
      end
      
      function set.options(obj, values)
      % option list has four columns:
      % 1. Name of the option
      % 2. Possible values: either numerical limits (matrix) or list (cell array)
      % 3. Default value
      %
         try 
            obj.checkValues(values)
            obj.options = values;
         catch e
            error(e.message)
         end
      end
      
      function checkValues(obj, values)
         nOptions = size(obj.optionList, 1);
         if nOptions > 0
            if numel(values) ~= nOptions
               error('Specify all values for the method (%d)!', nOptions);
            else
               for i = 1:nOptions
                  limits = obj.optionList{i, 2};
                  if ~isempty(limits)
                     if iscell(limits)
                        if isnumeric(values{i})
                           res = ismember(values{i}, [limits{:}]);
                        else
                           res = ismember(values{i}, limits);
                        end
                        
                        if ~res
                           throw(MException('prepItem:WrongValue', ...
                              sprintf('Wrong value for parameter "%s"!', obj.optionList{i, 1})));
                        end                        
                     else
                        if values{i} < limits(1) || values{i} > limits(2)
                           throw(MException('prepItem:WrongValue', ...
                              sprintf('Wrong value for parameter "%s"!', obj.optionList{i, 1})));
                        end
                     end   
                  end   
               end   
            end
         end   
      end
      
      function reset(obj)
         if ~isempty(obj.optionList)
            obj.options = obj.optionList(:, 3);
         end   
      end   
   end
   
   methods (Static = true)
   end
end   