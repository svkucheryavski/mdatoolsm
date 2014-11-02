classdef prepSnv < prepItem
   methods
      function obj = prepSnv(varargin)
         obj = obj@prepItem(varargin{:});
         obj.name = 'snv';
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns

         means = mean(values, 2);
         stds = std(values, 0, 2);
         values = bsxfun(@minus, values', means');
         out = bsxfun(@rdivide, values, stds')';
       end   
   end   
end   